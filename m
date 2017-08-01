From: yujuan.qi <yujuan.qi-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] Cipso: cipso_v4_optptr enter infinite loop
Date: Tue, 1 Aug 2017 16:54:04 +0800
Message-ID: <1501577644.32665.25.camel@mwhsdaap41>
References: <1501471381-12808-1-git-send-email-yujuan.qi@mediatek.com>
 <CAGH-KguiiVTyxHp0Z3Z==6b5n2h3Lm4SmU=ruydMpGgctdhYSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ryder Lee <ryder.lee-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <CAGH-KguiiVTyxHp0Z3Z==6b5n2h3Lm4SmU=ruydMpGgctdhYSw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi
On Mon, 2017-07-31 at 16:13 -0400, Paul Moore wrote:
> On Sun, Jul 30, 2017 at 11:23 PM, Yujuan Qi <yujuan.qi-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org> wrote:
> > From: "yujuan.qi" <yujuan.qi-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> >
> > in for(),if((optlen > 0) && (optptr[1] == 0)), enter infinite loop.
> >
> > Test: receive a packet which the ip length > 20 and t he first byte of ip option is 0, produce this issue
> >
> > Signed-off-by: yujuan.qi <yujuan.qi-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> > ---
> >  net/ipv4/cipso_ipv4.c | 12 ++++++++++--
> >  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> Considering I gave you the code below I should probably ack it, right? ;)
> 
> Acked-by: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>

Yes! Thanks for your suggestions!

> > diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
> > index ae20616..0d1e07d 100644
> > --- a/net/ipv4/cipso_ipv4.c
> > +++ b/net/ipv4/cipso_ipv4.c
> > @@ -1523,9 +1523,17 @@ unsigned char *cipso_v4_optptr(const struct sk_buff *skb)
> >         int taglen;
> >
> >         for (optlen = iph->ihl*4 - sizeof(struct iphdr); optlen > 0; ) {
> > -               if (optptr[0] == IPOPT_CIPSO)
> > +               switch (optptr[0]) {
> > +               case IPOPT_CIPSO:
> >                         return optptr;
> > -               taglen = optptr[1];
> > +               case IPOPT_END:
> > +                       return NULL;
> > +               case IPOPT_NOOP:
> > +                       taglen = 1;
> > +                       break;
> > +               default:
> > +                       taglen = optptr[1];
> > +               }
> >                 optlen -= taglen;
> >                 optptr += taglen;
> >         }
> 
