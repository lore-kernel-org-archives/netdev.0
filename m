From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v5 2/4] ifstat: Add extended statistics to
 ifstat
Date: Tue, 7 Feb 2017 08:48:53 -0800
Message-ID: <20170207084853.3ed6988e@xeon-e3>
References: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
        <1485434681-33947-3-git-send-email-nogahf@mellanox.com>
        <20170203100725.3d0b9791@xeon-e3>
        <DB5PR05MB1895D24A0C4AD0F7832EDC4EAC430@DB5PR05MB1895.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "roszenrami@gmail.com" <roszenrami@gmail.com>,
        "jbenc@redhat.com" <jbenc@redhat.com>,
        "sergei.shtylyov@cogentembedded.com"
        <sergei.shtylyov@cogentembedded.com>,
        Jiri Pirko <jiri@mellanox.com>,
        "Elad Raz" <eladr@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33588 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754536AbdBGQs5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 11:48:57 -0500
Received: by mail-pg0-f47.google.com with SMTP id 204so40180367pge.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 08:48:57 -0800 (PST)
In-Reply-To: <DB5PR05MB1895D24A0C4AD0F7832EDC4EAC430@DB5PR05MB1895.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Feb 2017 12:59:11 +0000
Nogah Frankel <nogahf@mellanox.com> wrote:

> > -----Original Message-----
> > From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> > Sent: Friday, February 03, 2017 8:07 PM
> > To: Nogah Frankel <nogahf@mellanox.com>
> > Cc: netdev@vger.kernel.org; roopa@cumulusnetworks.com; roszenrami@gmail.com;
> > jbenc@redhat.com; sergei.shtylyov@cogentembedded.com; Jiri Pirko
> > <jiri@mellanox.com>; Elad Raz <eladr@mellanox.com>; Ido Schimmel
> > <idosch@mellanox.com>; Yotam Gigi <yotamg@mellanox.com>; Or Gerlitz
> > <ogerlitz@mellanox.com>
> > Subject: Re: [PATCH iproute2 v5 2/4] ifstat: Add extended statistics to ifstat
> > 
> > On Thu, 26 Jan 2017 14:44:39 +0200
> > Nogah Frankel <nogahf@mellanox.com> wrote:
> >   
> > > Extended stats are part of the RTM_GETSTATS method. This patch adds them
> > > to ifstat.
> > > While extended stats can come in many forms, we support only the
> > > rtnl_link_stats64 struct for them (which is the 64 bits version of struct
> > > rtnl_link_stats).
> > > We support stats in the main nesting level, or one lower.
> > > The extension can be called by its name or any shorten of it. If there is
> > > more than one matched, the first one will be picked.
> > >
> > > To get the extended stats the flag -x <stats type> is used.
> > >
> > > Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> > > Reviewed-by: Jiri Pirko <jiri@mellanox.com>  
> > 
> > Sorry I was confused because RTM_GETSTATS contains multiple statistics.
> > Your patch is about getting LINK_XSTATS and after looking in more detail, you are
> > correct this should be an option. Although it would make sense to show this as addition
> > to the basic statistics. And when I tested it no output happens which seems confusing.
> > 
> > $ ./misc/ifstat -p -x cpu_hits
> > #kernel
> > Interface        RX Pkts/Rate    TX Pkts/Rate    RX Data/Rate    TX Data/Rate
> >                  RX Errs/Drop    TX Errs/Drop    RX Over/Rate    TX Coll/Rate
> >   
> 
> Not all devices support this xstat.
> Do you prefer another print in this case?
> 
> About printing both the xstat and the default stats together, it may be problematic since 
> ifstat is about diffs. I think it is better that one ifstat call for a specific stats, won't change
> the other stats data. (And since we are talking about diffs, reading data meaning changing
> it).

Maybe an error would be a better experience for  user.
I merged the current version but try and think about how to make it work better in general.
