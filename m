From: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>
Subject: Re: [Fwd: [patch 02/15] ppp_mppe: add PPP MPPE encryption module]
Date: Fri, 8 Jul 2005 22:57:15 +1000
Message-ID: <17102.30763.326707.473425@cargo.ozlabs.ibm.com>
References: <42B747C9.7060901@pobox.com>
	<17102.26269.264419.345257@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm-3NddpPZAyC0@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matt_Domsch-8PEkshWhKlo@public.gmane.org, Brice.Goglin-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org,
	james.cameron-VXdhtT5mjnY@public.gmane.org, pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
In-Reply-To: <17102.26269.264419.345257-UYQwCShxghk5kJ7NmlRacFaTQe2KTcn/@public.gmane.org>
Sender: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=pptpclient-devel>
List-Id: netdev.vger.kernel.org

To follow up on my comments on the mppe patch, it still misses the
most important thing, which is to make sure you don't send unencrypted
data if CCP should go down.  A received CCP TermReq or TermAck will
clear the SC_DECOMP_RUN flag and the code will then ignore the
xcomp->must_compress flag.

I really think there should be another flag bit set by pppd to say
"must compress" rather than relying on the compressor telling you
that.

Paul.


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
