From: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
Subject: Re: Re: TSO and IPoIB performance degradation
Date: Tue, 07 Mar 2006 13:44:51 -0800
Message-ID: <1141767891.6119.903.camel@localhost>
References: <OF336D72E6.999D2A30-ON8725712A.00117C92-8825712A.00116629@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	openib-general@openib.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <openib-general-bounces@openib.org>
To: Shirley Ma <xma@us.ibm.com>
In-Reply-To: <OF336D72E6.999D2A30-ON8725712A.00117C92-8825712A.00116629@us.ibm.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-03-06 at 19:13 -0800, Shirley Ma wrote:
> 
> > More likely you are getting hit by the fact that TSO prevents the
> congestion
> window from increasing properly. This was fixed in 2.6.15 (around mid
> of Nov 2005). 
> 
> Yep, I noticed the same problem. After updating to the new kernel, the
> performance are much better, but it's still lower than before.

 Here is an updated version of OpenIB IPoIB performance for various
kernels with and without one of the TSO patches.  The netperf
performance for the latest kernels has not improved the TSO performance
drop.

  Any comments or suggestions would be appreciated.

  - Matt

> 
All benchmarks are with RHEL4 x86_64 with HCA FW v4.7.0
dual EM64T 3.2 GHz PCIe IB HCA (memfull)
patch 1 - remove changeset 314324121f9b94b2ca657a494cf2b9cb0e4a28cc

Kernel                OpenIB    msi_x  netperf (MB/s)  
2.6.16-rc5           in-kernel    1     367
2.6.15               in-kernel    1     382
2.6.14-rc4 patch 1   in-kernel    1     434 
2.6.14-rc4           in-kernel    1     385 
2.6.14-rc3           in-kernel    1     374 
2.6.13.2             svn3627      1     386 
2.6.13.2 patch 1     svn3627      1     446 
2.6.13.2             in-kernel    1     394 
2.6.13-rc3 patch 12  in-kernel    1     442 
2.6.13-rc3 patch 1   in-kernel    1     450 
2.6.13-rc3           in-kernel    1     395
2.6.12.5-lustre      in-kernel    1     399  
2.6.12.5 patch 1     in-kernel    1     464
2.6.12.5             in-kernel    1     402 
2.6.12               in-kernel    1     406 
2.6.12-rc6 patch 1   in-kernel    1     470 
2.6.12-rc6           in-kernel    1     407
2.6.12-rc5           in-kernel    1     405 
2.6.12-rc5 patch 1   in-kernel    1     474
2.6.12-rc4           in-kernel    1     470 
2.6.12-rc3           in-kernel    1     466 
2.6.12-rc2           in-kernel    1     469 
2.6.12-rc1           in-kernel    1     466
2.6.11               in-kernel    1     464 
2.6.11               svn3687      1     464 
2.6.9-11.ELsmp       svn3513      1     425  (Woody's results, 3.6Ghz
EM64T) 
