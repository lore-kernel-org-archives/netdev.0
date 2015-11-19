From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Thu, 19 Nov 2015 10:49:21 +0100
Message-ID: <564D9B21.302@profihost.ag>
References: <564B3D35.50004@profihost.ag>
 <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
 <alpine.DEB.2.11.1511172041480.3761@nanos> <564CDE2F.8000201@profihost.ag>
 <564CEB0C.40006@redhat.com> <564CEF5D.3080005@profihost.ag>
 <564D9A17.6080305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Weimer <fweimer@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <564D9A17.6080305@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Am 19.11.2015 um 10:44 schrieb Florian Weimer:
> On 11/18/2015 10:36 PM, Stefan Priebe wrote:
> 
>>> please try to get a backtrace with debugging information.  It is likely
>>> that this is the make_request/__check_pf functionality in glibc, but it
>>> would be nice to get some certainty.
>>
>> sorry here it is. What I'm wondering is why is there ipv6 stuff? I don't
>> have ipv6 except for link local.
> 
> glibc needs to know if the system has global unicast addresses if it
> receives AAAA records.
> 
> It's curious that net.ipv6.conf.all.disable_ipv6=1 makes the problem go
> away.  Even with that setting, the kernel seems to send two Netlink
> responses.  So either this is enough to narrow the window for the race
> so that no longer triggers, or there is a genuine kernel issue with
> supplying the requested IPv6 Netlink response.

No idea it also goes away by downgrading to 3.18 again.

Stefan

>> Could it be this one?
>>
>> https://bugzilla.redhat.com/show_bug.cgi?id=505105#c79
> 
> No, that's on the DNS/UDP side, not in the Netlink code.
> 
> Florian
> 
