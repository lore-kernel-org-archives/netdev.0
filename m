From: James Harper <james.harper@bendigoit.com.au>
Subject: Re: [PATCH 4/4] xen-netback: coalesce slots before
 copying
Date: Mon, 18 Mar 2013 13:27:29 +0000
Message-ID: <6035A0D088A63A46850C3988ED045A4B387EC8DC@BITCOM1.int.sbss.com.au>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	<1363602955-24790-5-git-send-email-wei.liu2@citrix.com>
	<6035A0D088A63A46850C3988ED045A4B387EC758@BITCOM1.int.sbss.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "annie.li@oracle.com" <annie.li@oracle.com>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: James Harper <james.harper@bendigoit.com.au>, Wei Liu
	<wei.liu2@citrix.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <6035A0D088A63A46850C3988ED045A4B387EC758@BITCOM1.int.sbss.com.au>
Content-Language: en-US
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

> >
> > This patch tries to coalesce tx requests when constructing grant copy
> > structures. It enables netback to deal with situation when frontend's
> > MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
> >
> > It defines max_skb_slots, which is a estimation of the maximum number of
> > slots
> > a guest can send, anything bigger than that is considered malicious. Now it
> is
> > set to 20, which should be enough to accommodate Linux (16 to 19) and
> > possibly
> > Windows (19?).
> >
> > +/*
> > + * This is an estimation of the maximum possible frags a SKB might
> > + * have, anything larger than this is considered malicious. Typically
> > + * Linux has 16 to 19, Windows has 19(?).
> > + */
> 
> Could you remove the "Windows has 19(?)" comment? I don't think it's
> helpful, even with the "(?)"... I just checked and windows 2008R2 gives
> GPLPV a maximum of 20 buffers in all the testing I've done, and that's after
> the header is coalesced so it's probably more than that. I'm pretty sure I
> tested windows 2003 quite a while back and I could coax it into giving
> ridiculous numbers of buffers when using iperf with tiny buffers.
> 
> Maybe "Windows has >19" if you need to put a number on it?
> 

Actually it turns out GPLPV just stops counting at 20. If I keep counting I can sometimes see over 1000 buffers per GSO packet under Windows using "iperf -l50", so windows will quite happily send 1000's of buffers and I don't have any evidence that it wouldn't cope with a similar number on receive. fwiw.

(of course coalescing vs using 1000 ring slots is an obvious choice...)

James
