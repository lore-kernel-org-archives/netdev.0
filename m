From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 2/2] net/sched: allow
 flower to match tunnel options
Date: Wed, 13 Sep 2017 11:25:12 +0200
Message-ID: <20170913092511.GA27555@vergenet.net>
References: <1505226037-2758-1-git-send-email-simon.horman@netronome.com>
 <1505226037-2758-3-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgfkpJCfZX-7jaeYtoWTSQQZ6gu8_jSFgcXpzTBpdijQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:45071 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751380AbdIMJZO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 05:25:14 -0400
Received: by mail-wm0-f43.google.com with SMTP id g206so1783138wme.0
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 02:25:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgfkpJCfZX-7jaeYtoWTSQQZ6gu8_jSFgcXpzTBpdijQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 12, 2017 at 11:23:55PM +0300, Or Gerlitz wrote:
> On Tue, Sep 12, 2017 at 5:20 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > Allow matching on options in tunnel headers.
> > This makes use of existing tunnel metadata support.
> 
> Simon,
> 
> This patch is about matching on tunnel options, right? but
> 
> > Options are a bytestring of up to 256 bytes.
> > Tunnel implementations may support less or more options,
> > or no options at all.
> >
> >  # ip link add name geneve0 type geneve dstport 0 external
> >  # tc qdisc add dev eth0 ingress
> >  # tc qdisc del dev eth0 ingress; tc qdisc add dev eth0 ingress
> >  # tc filter add dev eth0 protocol ip parent ffff: \
> >      flower indev eth0 \
> >         ip_proto udp \
> >         action tunnel_key \
> >             set src_ip 10.0.99.192 \
> >             dst_ip 10.0.99.193 \
> >             dst_port 4789 \
> >             id 11 \
> >             opts 0102800100800022 \
> >     action mirred egress redirect dev geneve0
> 
> the example here is on how to use tunnel options in the tunnel set key actions..
> 
> And the other way around in the other patch... the patch is about the
> tunnel key set action and the example shows how to match that in
> flower... I guess you want to swap the relevant of the change log.

Yes, it seems so. Sorry about that.

> Anyway, is there any human readable/understandable representation of
> these options? e.g what does 0102800100800022 means for geneve?

Thanks, I had not thought of that. My feeling is that could
be added to the tc tool as follow-up work.
