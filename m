From: Shirley Ma <xma@us.ibm.com>
Subject: [ofa-general] Re: InfiniBand/RDMA merge plans for 2.6.24
Date: Wed, 3 Oct 2007 11:43:40 -0700
Message-ID: <OF9591AF85.09F0D1BF-ON87257369.006651BA-88257369.0066A0BD@us.ibm.com>
References: <ada1wcxnev5.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org, netdev-owner@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <ada1wcxnev5.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Roland Dreier <rdreier@cisco.com> wrote on 09/17/2007 02:47:42 PM:

>  > > IPoIB CM handles this properly by gathering together single pages 
in
>  > > skbs' fragment lists.
> 
>  > Then can we reuse IPoIB CM code here?
> 
> Yes, if possible, refactoring things so that the rx skb allocation
> code becomes common between CM and non-CM would definitely make sense.

IPoIB-CM rx skb allocation is not generic to be used by UD, it allocates 
more buffers than needed if mtu is not 64K, and doesn't query the real 
max_num_sg from the device. I am thinking to have a generic skb allocation 
in IPoIB based on matrix of (ipoib-mtu-size, page-size, max_num_sg, 
head-size).

Thanks
Shirley 
