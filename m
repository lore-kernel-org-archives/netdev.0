From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: 14 Jan 2003 08:46:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1042526764.2606.21.camel@devil>
References: <Pine.LNX.4.33.0301131651170.1861-100000@dyn9-47-18-98.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, Jon Grimm <jgrimm2@us.ibm.com>, davem@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.33.0301131651170.1861-100000@dyn9-47-18-98.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-01-14 at 02:56, Sridhar Samudrala wrote:
> On 14 Jan 2003, Mika Liljeberg wrote:
> 
> > Hi,
> > 
> > I know this is not what the SCTP spec recommends with IPv4, but what
> > prevents you from just fragmenting the IP packets at the source and
> > setting the DF bit on each fragment (assuming you can't just repackage
> > the data chunks)? This would be equivalent to the IPv6 behaviour and
> > would keep PMTUD working perfectly.
> 
> SCTP does segment the packets based on the current PMTU and sets DF bit to not
> allowing IP fragmentation. The problem occurs when the PMTU shrinks and there
> are outstanding segmented packets which need to be retransmitted. We cannot
> re-segment these packets, but would like IP to fragment them by not setting
> DF bit. 

Setting DF=0 allows intermediate routers to fragment the packets as
well. I was proposing that you allow the IP layer to fragment the
packets at source host only, and then set DF=1 on the IP fragments. This
should keep PMTUD working nicely, since intermediate routers are not
allowed to refragment.

	MikaL
