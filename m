From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [iproute PATCH v2 2/7] Use C99 style initializers everywhere
Date: Wed, 22 Jun 2016 11:41:30 +0200
Message-ID: <87lh1xmugl.fsf@frog.home>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc> <1466525921-15738-3-git-send-email-phil@nwl.cc> <87mvmdmvtd.fsf@frog.home> <20160622092958.GA15980@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <shemming@brocade.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35193 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbcFVJlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 05:41:35 -0400
Received: by mail-qk0-f172.google.com with SMTP id c73so56979204qkg.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 02:41:34 -0700 (PDT)
In-reply-to: <20160622092958.GA15980@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 11:29 AM CEST, Phil Sutter <phil@nwl.cc> wrote:
> On Wed, Jun 22, 2016 at 11:12:14AM +0200, Jakub Sitnicki wrote:
>> On Tue, Jun 21, 2016 at 06:18 PM CEST, Phil Sutter <phil@nwl.cc> wrote:
>> > This big patch was compiled by vimgrepping for memset calls and changing
>> > to C99 initializer if applicable. One notable exception is the
>> > initialization of union bpf_attr in tc/tc_bpf.c: changing it would break
>> > for older gcc versions (at least <=3.4.6).
>> >
>> > Calls to memset for struct rtattr pointer fields for parse_rtattr*()
>> > were just dropped since they are not needed.
>> >
>> > The changes here allowed the compiler to discover some unused variables,
>> > so get rid of them, too.
>> >
>> > Signed-off-by: Phil Sutter <phil@nwl.cc>
>> > ---
>> 
>> [...]
>> 
>> > diff --git a/bridge/fdb.c b/bridge/fdb.c
>> > index be849f980a802..a59d6a9c13018 100644
>> > --- a/bridge/fdb.c
>> > +++ b/bridge/fdb.c
>> > @@ -177,16 +177,15 @@ static int fdb_show(int argc, char **argv)
>> >  		struct nlmsghdr	n;
>> >  		struct ifinfomsg	ifm;
>> >  		char			buf[256];
>> > -	} req;
>> > +	} req = {
>> > +		.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
>> > +		.ifm.ifi_family = PF_BRIDGE
>> > +	};
>> >  
>> 
>> A comma is allowed after a list of initializers (IOW, after the last
>> initializer). Having it would make for smaller/cleaner diffs in the
>> future if new structure members get added and need to be initialized.
>
> Good point! I knew about that already, but that's good reasoning why one
> would actually want to do that intentionally.

It also helps us all with the compulsive need for closure ;-)

Thanks,
Jakub
