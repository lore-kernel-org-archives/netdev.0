From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH iproute2] vxlan: allow specifying multiple default destinations
Date: Wed, 5 Jun 2013 15:58:50 +0300
Message-ID: <CAF1J0HO9USZXOj3nJnZ2Eup5Q4c2VhavgH0fmHFY1oUaWB+_UQ@mail.gmail.com>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-4-git-send-email-mike.rapoport@ravellosystems.com>
	<ko4kcr$h8j$1@ger.gmane.org>
	<CAF1J0HPDAkhAybQt-tOFLLTLzaXiWy_TSbFF2FT3PMaXbnxJuw@mail.gmail.com>
	<20130529155625.2ee5f6bb@nehalam.linuxnetplumber.net>
	<CAF1J0HNiBED=BLHqPPk8w2=DDvSWdZwMPvtag6rpPhxnboT4GA@mail.gmail.com>
	<20130530114424.GC10532@casper.infradead.org>
	<20130530124652.GA29547@zed.ravello.local>
	<20130530155719.GD10532@casper.infradead.org>
	<CAF1J0HP4Oi04PK-JFwy1h7_n=MxiA-c5DTjPSTHjwGrxs+jUZg@mail.gmail.com>
	<20130604213055.7e1fc67c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Thomas Graf <tgraf@suug.ch>, Cong Wang <xiyou.wangcong@gmail.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog104.obsmtp.com ([74.125.245.76]:50165 "HELO
	na3sys010aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754926Ab3FEM6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 08:58:51 -0400
Received: by mail-ob0-f182.google.com with SMTP id va7so2523879obc.13
        for <netdev@vger.kernel.org>; Wed, 05 Jun 2013 05:58:50 -0700 (PDT)
In-Reply-To: <20130604213055.7e1fc67c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 5, 2013 at 7:30 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Sun, 2 Jun 2013 10:09:23 +0300
> Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>
>> On Thu, May 30, 2013 at 6:57 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> > On 05/30/13 at 03:46pm, Mike Rapoport wrote:
>> >> I'm feeling Ok about "ip link set [..] dstadd/dstdel". What does bother
>> >> me is that you can't have different parameters for "ip link add" and "ip
>> >> link set" for vxlan (and other iplink) utility. So, one can use
>> >> ip link add [..] dstdel
>> >> which does not make sense...
>> >
>> > You can easily pass an additional argument into iplink_modify()
>> > and exclude certain options in the "add" use case.
>>
>> I think there's no need to pass an additional argument to iplink_modify.
>> The vxlan_parse_opts may check the flags in nlmsghdr to distinguish
>> between the "add" and "set" cases.
>> Than we'll have 'ip link add [..]' as it was and the 'ip link set
>> [..]' will be used to manage default destinations.
>>
>> --
>> Sincerely yours,
>> Mike.
>
>
> I think multiple destinations should be handled like multipath routes.
> I.e you don't specify multiple destinations on the command line, you specify them
> individually and can add/delete them
>
> If you delete the last destination then the forwarding entry should disappear.
> The collapsing of multiple entries into one entry in table is an internal data structure
> choice of vxlan and shouldn't be part of the netlink API requirement.
>
> The API to iproute2/netlink should look like routing (through bridge fdb command).
> Feel free to reject this if since I don't actually use this stuff.

Well, if we're to follow David Stevens suggestion to make default
destination fdb entry with ALL_ZEROS_MAC (1), they surely can be
managed using 'bridge fdb'.

(1) http://thread.gmane.org/gmane.linux.network/270969/focus=271791

--
Sincerely yours,
Mike.
