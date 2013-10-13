From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH 2/3] net: bpf jit: x86: optimize choose_load_func error
 path
Date: Sun, 13 Oct 2013 16:31:21 +0200
Message-ID: <20131013143022.GA2029@hp530>
References: <1381249910-17338-1-git-send-email-murzin.v@gmail.com>
 <1381249910-17338-2-git-send-email-murzin.v@gmail.com>
 <20131011.145613.332487610005117559.davem@davemloft.net>
 <20131013142115.GA1872@hp530>
 <alpine.LNX.2.00.1310131824180.2262@linmac>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaffeemonster@googlemail.com, edumazet@google.com,
	mingo@redhat.com, tglx@linutronix.de
To: malc <av1474@comtv.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:53896 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855Ab3JMOby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 10:31:54 -0400
Received: by mail-lb0-f174.google.com with SMTP id w6so4869032lbh.33
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 07:31:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1310131824180.2262@linmac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 13, 2013 at 06:25:34PM +0400, malc wrote:
> On Sun, 13 Oct 2013, Vladimir Murzin wrote:
> 
> > On Fri, Oct 11, 2013 at 02:56:13PM -0400, David Miller wrote:
> > > From: Vladimir Murzin <murzin.v@gmail.com>
> > > Date: Tue,  8 Oct 2013 20:31:49 +0400
> > > 
> 
> [..snip..]
> 
> > -common_load:			seen |= SEEN_DATAREF;
> > +common_load:
> > +				if (!func) {
> > +					CLEAR_A();
> > +					EIT_JMP(cleanup_addr - addrs[i]);
> 
>                                         EMIT? (likewise elsewhere)
Oops... Thanks for quick response!

I'd better send the patch as a separate message.

> 
> > +					break;
> > +				}
> > +
> > +				seen |= SEEN_DATAREF;
> >  				t_offset = func - (image + addrs[i]);
> >  				EMIT1_off32(0xbe, K); /* mov imm32,%esi */
> >  				EMIT1_off32(0xe8, t_offset); /* call */
> > @@ -624,6 +631,13 @@ common_load:			seen |= SEEN_DATAREF;
> >  				goto common_load;
> >  			case BPF_S_LDX_B_MSH:
> >  				func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
> > +
> > +				if (!func) {
> > +					CLEAR_A();
> > +					EIT_JMP(cleanup_addr - addrs[i]);
> > +					break;
> > +				}
> > +
> >  				seen |= SEEN_DATAREF | SEEN_XREG;
> >  				t_offset = func - (image + addrs[i]);
> >  				EMIT1_off32(0xbe, K);	/* mov imm32,%esi */
> > 
> 
> -- 
> mailto:av1474@comtv.ru
