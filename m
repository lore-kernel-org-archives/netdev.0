From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 22:19:33 -0500
Message-ID: <547546C5.3060207@mojatatu.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>	<1416911328-10979-3-git-send-email-jiri@resnulli.us>	<5474A25C.3080505@mojatatu.com>	<5474A7EE.8000300@intel.com>	<5474ABF0.60901@mojatatu.com>	<5474AE9B.6000500@intel.com>	<5474B353.10802@mojatatu.com> <CAE4R7bD1Hi+fnKp-Sg6Tn4AcpOu2pwgEYecP8LVA1ioO4FkgRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:56407 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbaKZDTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 22:19:48 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so1886871ier.27
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 19:19:48 -0800 (PST)
In-Reply-To: <CAE4R7bD1Hi+fnKp-Sg6Tn4AcpOu2pwgEYecP8LVA1ioO4FkgRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 21:36, Scott Feldman wrote:
> On Tue, Nov 25, 2014 at 6:50 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> On 11/25/14 11:30, John Fastabend wrote:

>> Ok, guess i am gonna have to go stare at the code some more.
>> I thought we returned one of the error codes?
>> A bitmask would work for a single entry - because you have two
>> options add to h/ware and/or s/ware. So response is easy to encode.
>> But if i have 1000 and they are sparsely populated (think an indexed
>> table and i have indices 1, 23, 45, etc), then a bitmask would be
>> hard to use.
>
> I'm confused by this discussion.

This is about the policy which states "install as many as you can, dont
worry about failures". In such a case, how do you tell user space back
"oh, btw you know your request #1, #23, and 45 went ok, but nothing else
worked". A simple return code wont work. You could return a code to
say "some worked". At which case user space could dump and find out only
#1, #23 and #45 worked.

Your question below is a different context; Some people may want
the policy where whats in hardware
a) gets to be seen in software and b) allow for destination lookup
failures in hardware to show up in the kernel, refresh the fdb in the
kernel via learning
and c) whats in s.ware gets synced to hardware just because there's
space in the hardware
I dont want any of the above;-> Which would work if we had policy knobs.
Learning, flooding, sync from hardware. Speaking of the last one:
Where is my cookie Scott? I want my cookie.

cheers,
jamal


> Do I have this right: You want to
> send 1000 RTM_NEWNEIGHs to PF_BRIDGE with both NTF_MASTER and NTF_SELF
> set such that 1000 new FBD entries are installed in both (SW) the
> bridge's FDB and (HW) the port driver's FDB.  My first confusion is
> why do you want these FBD entries in bridge's FDB?  We're offloading
> the switching to HW so HW should be handling fwd plane.  If ctrl pkt
> make it to SW, it can learn those FDB entries;
> no need for manual
> install of FDB entry in SW.  It seems to me you only want to use
> NTF_SELF to install the FDB entry in HW using the port driver.  And an
> error code is returned for that install.  Since there is only one
> target (NTF_SELF) there is no need for bitmask return.
