From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] staging: rtlwifi: Improve debugging by using debugfs
Date: Fri, 25 Aug 2017 15:00:22 -0700
Message-ID: <CAKgT0UeKhQ7ENbWPbEWw1YNK2EXoj0=9Vvksja-CaRdO_0yc-g@mail.gmail.com>
References: <20170824212808.26632-1-Larry.Finger@lwfinger.net>
 <20170825015421.GA8852@lunn.ch>
 <1a1ca849-3aec-60e3-b5a3-98a6e095d298@lwfinger.net>
 <20170825141647.GA30922@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Yan-Hsuan Chuang <yhchuang@realtek.com>,
 gregkh@linuxfoundation.org, Birming Chiu <birming@realtek.com>,
 Netdev <netdev@vger.kernel.org>, Steven Ting <steventing@realtek.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170825141647.GA30922@lunn.ch>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Fri, Aug 25, 2017 at 7:16 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Fri, Aug 25, 2017 at 08:47:00AM -0500, Larry Finger wrote:
>> On 08/24/2017 08:54 PM, Andrew Lunn wrote:
>> >netdev frowns upon debugfs. You should try to keep this altogether,
>> >making it easy to throw away before the driver is moved out of
>> >staging.
>> >
>> >You might want to look at ethtool -d. That will be accepted.
>>
>> Andrew,
>>
>> What is the problem with debugfs?
>
> You should probably look back in the discussions on the netdev
> mailling list. But basically, anything you want to export should
> follow generic well defined interface, which can be used by other
> drivers. debugfs tends to be a mess, a wild west, each driver doing
> its own thing, not standardisation. It is O.K. for your own
> development work, you can have your own out of tree patches adding in
> debugfs, but such patches are unlikely to be accepted into mainline.
> David has threatened to simply rip out all debugfs code from all
> network drivers. There is push back on adding any new debugfs code,
> and some driver writers have taken out debugfs code in their own
> drivers, often replacing it with something generic all drivers can
> use.

I think the bigger issue is that many people end up using debugfs to
try and configure things, or they create redundant functionality with
existing interfaces which is generally frowned upon. So generally it
is okay for things like peeking into driver state machines, or as a
means to dump descriptor rings, but not okay for using to program
filters, write registers, change the device state, or collect generic
statistics.
