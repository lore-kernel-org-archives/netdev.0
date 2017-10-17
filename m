From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [RFC] sctp: suspicious rcu_read_lock() in sctp_packet_config()
Date: Tue, 17 Oct 2017 14:28:26 -0200
Message-ID: <20171017162826.GB5357@localhost.localdomain>
References: <1508247956.31614.103.camel@edumazet-glaptop3.roam.corp.google.com>
 <CADvbK_dRBaOLzrXWS2ndHu3sz9LB87rJsyGog2BjishapiMhxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        netdev <netdev@vger.kernel.org>, Wei Wang <weiwan@google.com>,
        Eric Dumazet <edumazet@google.com>, linux-sctp@vger.kernel.org
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54096 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753306AbdJQQ23 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 12:28:29 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_dRBaOLzrXWS2ndHu3sz9LB87rJsyGog2BjishapiMhxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 11:31:30PM +0800, Xin Long wrote:
> On Tue, Oct 17, 2017 at 9:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > SCTP experts.
> >
> > syszkaller reported a few crashes in sctp_packet_config() with invalid
> > access to a deleted dst.
> >
> > The rcu_read_lock() in sctp_packet_config() is suspect.
> >
> > It does not protect anything at the moment.
> >
> > If we expect tp->dst to be manipulated/changed by another cpu/thread,
> > then we need proper rcu protection.
> >
> > Following patch to show what would be a minimal change (but obviously
> > bigger changes are needed, like sctp_transport_pmtu_check() and
> > sctp_transport_dst_check(), and proper sparse annotations)
> will check all places accessing tp->dst in sctp.

I checked some and sctp_transport_dst_check() should be fine because
by then we are holding a reference on dst. Same goes to
sctp_transport_pmtu_check().  It's not possible that these would trip
on the update going on on sctp_packet_config() because the socket is
locked. We may not need (much) more than the example patch, I think.

A more thorough check is certainly welcomed, indeed.

  Marcelo
