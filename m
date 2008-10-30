From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH] Fix logic error in rfkill_check_duplicity
Date: Thu, 30 Oct 2008 18:49:05 -0200
Message-ID: <20081030204905.GB29976@khazad-dum.debian.net>
References: <20081029164006.GH3162@earth.li> <1225309212.3068.44.camel@achroite> <20081030102746.GI3162@earth.li> <20081030144409.GJ3162@earth.li>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jonathan McDowell <noodles@earth.li>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754913AbYJ3Ut0@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081030144409.GJ3162@earth.li>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Oct 2008, Jonathan McDowell wrote:
> On Thu, Oct 30, 2008 at 10:27:46AM +0000, Jonathan McDowell wrote:
> > I'll have a prod at why the [hso] rfkill stuff isn't working next
> 
> Ok, I believe this is due to the addition of rfkill_check_duplicity in
> rfkill and the fact that test_bit actually returns a negative value
> rather than the postive one expected (which is of course equally true).
> So when the second WLAN device (the hso device, with the EEE PC WLAN
> being the first) comes along rfkill_check_duplicity returns a negative
> value and so rfkill_register returns an error. Patch below fixes this
> for me.

Good catch, I screwed up on that one.  Please forward it with my ack to
linux-wireless@kernel.org and to Ivo van Doorn <IvDoorn@gmail.com> and John
W. Linville <linville@tuxdriver.com>.

Acked-by: Henrique de Moraes Holschuh <hmh@hmh.eng.br>

> -----
> diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
> index f949a48..1ba35a7 100644
> --- a/net/rfkill/rfkill.c
> +++ b/net/rfkill/rfkill.c
> @@ -603,7 +603,7 @@ static int rfkill_check_duplicity(const struct rfkill *rfkil
>         }
>  
>         /* 0: first switch of its kind */
> -       return test_bit(rfkill->type, seen);
> +       return (test_bit(rfkill->type, seen)) ? 1 : 0;
>  }
>  
>  static int rfkill_add_switch(struct rfkill *rfkill)
> -----
> 
> J.
> 

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
