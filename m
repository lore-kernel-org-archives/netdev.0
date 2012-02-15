From: Sameer Nanda <snanda@chromium.org>
Subject: Re: [PATCH 1/2] r8169: Enable WOL from Magic Packet by
	default
Date: Tue, 14 Feb 2012 17:00:04 -0800
Message-ID: <CANMivWax5jGNJLkjZWi2F5iaM+bnK0Ti1qZzQx4CGgkzeQqt7Q@mail.gmail.com>
References: <1329244079-27842-1-git-send-email-snanda@chromium.org>
	<20120215001342.GA11453@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	hayeswang@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <20120215001342.GA11453@electric-eye.fr.zoreil.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/linux-pm/>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 14, 2012 at 4:13 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Sameer Nanda <snanda@chromium.org> :
>> Set the WOL config registers to only enable WOL from magic packet by
>> default. Without this change in place, the WOL config register
>> settings on warm reboot come up in an inconsistent state since these
>> registers don't get reset on a warm reboot.
>
> I am not completely convinced, especially as the change of behavior
> could be noticed.

Agreed that this change could be noticed.  Maybe a module parameter
might be a better way to handle this?

>
> Can you elaborate why the previous WoL settings should be ignored ?

With runtime PM, the "previous" settings may not be what the user had
set up since runtime PM mucks around with WOL settings.  Therefore,
the user could see inconsistent WOL settings upon booting up.

My second patch in this series mitigates this to a large extent by
restoring the saved WOL options in rtl_shutdown.  One case it doesn't
handle is non-graceful shutdown since rtl_shutdown may not be invoked.

The issue we ran into is this: disconnect network cable, reboot
system.  This will cause WOL on PHY to be enabled on next boot.  If
you connect the cable and then transition the system to S3 state or
halt the system, the system wakes right back up since the PHY state
changes.  Not good.

>
> --
> Ueimor



-- 
Sameer
