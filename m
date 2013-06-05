From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vxlan: allow specifying multiple default
 destinations
Date: Tue, 4 Jun 2013 21:30:55 -0700
Message-ID: <20130604213055.7e1fc67c@nehalam.linuxnetplumber.net>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Cong Wang <xiyou.wangcong@gmail.com>,
	netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:64404 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab3FEEbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 00:31:01 -0400
Received: by mail-pd0-f179.google.com with SMTP id q11so1229243pdj.24
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 21:31:00 -0700 (PDT)
In-Reply-To: <CAF1J0HP4Oi04PK-JFwy1h7_n=MxiA-c5DTjPSTHjwGrxs+jUZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2 Jun 2013 10:09:23 +0300
Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:

> On Thu, May 30, 2013 at 6:57 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > On 05/30/13 at 03:46pm, Mike Rapoport wrote:
> >> I'm feeling Ok about "ip link set [..] dstadd/dstdel". What does bother
> >> me is that you can't have different parameters for "ip link add" and "ip
> >> link set" for vxlan (and other iplink) utility. So, one can use
> >> ip link add [..] dstdel
> >> which does not make sense...
> >
> > You can easily pass an additional argument into iplink_modify()
> > and exclude certain options in the "add" use case.
> 
> I think there's no need to pass an additional argument to iplink_modify.
> The vxlan_parse_opts may check the flags in nlmsghdr to distinguish
> between the "add" and "set" cases.
> Than we'll have 'ip link add [..]' as it was and the 'ip link set
> [..]' will be used to manage default destinations.
> 
> --
> Sincerely yours,
> Mike.


I think multiple destinations should be handled like multipath routes.
I.e you don't specify multiple destinations on the command line, you specify them
individually and can add/delete them

If you delete the last destination then the forwarding entry should disappear.
The collapsing of multiple entries into one entry in table is an internal data structure
choice of vxlan and shouldn't be part of the netlink API requirement.

The API to iproute2/netlink should look like routing (through bridge fdb command).
Feel free to reject this if since I don't actually use this stuff.
