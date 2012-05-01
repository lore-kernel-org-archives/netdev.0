From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] bridge: make brctl showstp display port id
Date: Tue, 1 May 2012 16:38:34 +0200
Message-ID: <OF4DD70AEF.9EE04586-ONC12579F1.00502FF3-C12579F1.00506F9C@transmode.se>
References: <1335775148-5191-1-git-send-email-Joakim.Tjernlund@transmode.se> <20120430090747.1d64198b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:39435 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753268Ab2EAOii (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 10:38:38 -0400
In-Reply-To: <20120430090747.1d64198b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote on 2012/04/30 18:07:47:
>
> On Mon, 30 Apr 2012 10:39:08 +0200
> Joakim Tjernlund <Joakim.Tjernlund@transmode.se> wrote:
>
> > My brctl showstp br0 always shows a 0 port id:
> > eth2 (1)
> >  port id      0         state             disabled
> >  designated root   8000.00069c00b2fb   path cost       100
> >
> > because port id is printed as a hex number in sys fs. Change the
> > two hex occurrences(port no and port id) to decimal, just like all
> > the other numbers in this area.
> >
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> >  net/bridge/br_sysfs_if.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
> > index fd5799c..9c4c2eb 100644
> > --- a/net/bridge/br_sysfs_if.c
> > +++ b/net/bridge/br_sysfs_if.c
> > @@ -86,13 +86,13 @@ static BRPORT_ATTR(designated_cost, S_IRUGO, show_designated_cost, NULL);
> >
> >  static ssize_t show_port_id(struct net_bridge_port *p, char *buf)
> >  {
> > -   return sprintf(buf, "0x%x\n", p->port_id);
> > +   return sprintf(buf, "%d\n", p->port_id);
> >  }
> >  static BRPORT_ATTR(port_id, S_IRUGO, show_port_id, NULL);
> >
> >  static ssize_t show_port_no(struct net_bridge_port *p, char *buf)
> >  {
> > -   return sprintf(buf, "0x%x\n", p->port_no);
> > +   return sprintf(buf, "%d\n", p->port_no);
> >  }
> >
> >  static BRPORT_ATTR(port_no, S_IRUGO, show_port_no, NULL);
>
> No. This would be a visible change to applications.
> The bridge utilities should be fixed instead.

Well, my reasoning was that if not the native tools got this right, what are the
chances that other apps got it right? I don't know any other apps than
brctl using this info, do you? We could check one or two apps to see what they do.

 Jocke
