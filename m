From: "Petr Vandrovec" <VANDROVE@vc.cvut.cz>
Subject: Re: [PATCH?] Fix sniffing of ARP replies
Date: Thu, 16 Oct 2003 12:07:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <32A9D366A0B@vcnet.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 15 Oct 03 at 20:47, David S. Miller wrote:
> On Wed, 15 Oct 2003 19:11:12 +0200
> Petr Vandrovec <vandrove@vc.cvut.cz> wrote:
> 
> >   after recent changes in packet_type interface I stopped setting
> > af_packet_priv - as you told that it is only for AF_PACKET, for nobody
> > else. And - things stopped working.
> 
> "Where" did you stop doing this?

vmnet. http://platan.vc.cvut.cz/ftp/pub/vmware/vmware-any-any-update42.tar.gz,
vmnet.tar -> bridge.c.
 
> Nothing in the current kernel should be broken at all by said
> changes I did to 2.6.x
> 
> If it has broken something you are working on external to the tree
> you have to say what it is.  I can only guess that it's making
> assumptions that never truly existed.

It behaves same way it behaved. But recently you renamed packet_type.data
to packet_type.af_packet_priv, saying that af_packet_priv should be used
only by AF_PACKET code, by nobody else. So I trusted you, removed
packet_type.data (and packet_type.af_packet_priv) references from the
code - and things stopped working, as with af_packet_priv==NULL ARP
replies are not delivered to the registered packet_type callback, as
these packets match skb->sk == pt->af_packet_priv for af_packet_priv == NULL.

I can of course set 'af_packet_priv' to some non-NULL value - but in such 
case I do not understand why you renamed it, if semantic is same as it was 
before.
                                                    Best regards,
                                                        Petr Vandrovec
                                                        vandrove@vc.cvut.cz
                                                        
