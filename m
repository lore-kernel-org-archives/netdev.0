From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 15:23:21 +0200
Message-ID: <468507C9.2000800@trash.net>
References: <1179827251.7707.29.camel@localhost.localdomain>	 <1179831825.4121.30.camel@localhost>	 <1180258853.7707.53.camel@localhost.localdomain>	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>	 <1181811576.5411.27.camel@localhost.localdomain>	 <1181820510.4091.9.camel@localhost>	 <1181869285.5411.39.camel@localhost.localdomain>	 <1182178882.4063.11.camel@localhost>	 <1182223964.5411.76.camel@localhost.localdomain>	 <1182811210.6644.22.camel@johannes.berg>	 <1182986681.5155.55.camel@localhost>	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net> <1183122920.4089.63.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183122920.4089.63.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Fri, 2007-06-29 at 15:11 +0200, Patrick McHardy wrote:
> 
> 
>>>Hm. I'm starting to dislike the dynamic registration the more I think
>>>about it. Now when a group is unregistered I'd have to unbind everybody
>>>who's currently using it... At least when I want to enforce
>>>root/non-root binds which is a further goal.
>>
>>
>>How about using module references to prevent unloading while sockets
>>are bound? We already do the same thing for netlink families.
> 
> 
> Ah, no, you're both thinking something different. I'm thinking if we
> allow dynamic registration the only sensible thing is to have dynamic
> unregistration as well, and then we can have this sequence
> 
>  (1) register group X with non-root
>  (2) non-root app A binds group X
>  (3) kernel unregisters group X
>  (4) something else in kernel reregisters group ID X but root-only
> -> non-root app A is bound to root-only group X


I'm not sure that "the only sensible thing to do" is right, we
do allow dynamic registration of netlink families and do the
module reference thing anyway (admittedly, I never liked that
and the autoloading part very much). I guess it depends on how
this will be used in the end, if you really do have a group per
device or something like that you probably need to be able to
unregister at any time. But as I said previously I believe its
more in the spirit of netlink to group things logically by
message type, in which case some core part would own the
family and not a single device.

If you do want the dynamic unregistation *and* the non-root mc
listening then I guess you don't have a choice but to unbind
sockets at unregistration. That shouln't be a real problem,
without having though much about it, I believe just clearing
the mc group from the bitmap and calling netlink_update_subscriptions
should be fine.

