From: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
Subject: Re: Timeline of IPoIB performance
Date: Wed, 12 Oct 2005 18:24:32 -0700
Message-ID: <1129166672.13948.530.camel@localhost>
References: <E1EPIxF-0001Cp-00@gondolin.me.apana.org.au>
	<52mzle7k2i.fsf@cisco.com>  <1129141706.13945.509.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rolandd@cisco.com>
In-Reply-To: <1129141706.13945.509.camel@localhost>
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

On Wed, 2005-10-12 at 11:28 -0700, Matt Leininger wrote:
> On Wed, 2005-10-12 at 09:53 -0700, Roland Dreier wrote:
> >     Herbert> Try reverting the changeset
> > 
> >     Herbert> 314324121f9b94b2ca657a494cf2b9cb0e4a28cc
> > 
> >     Herbert> which lies between these two points and may be relevant.
> > 
> > Matt, I pulled this out of git for you.  I guess Herbert is suggesting
> > to patch -R the below against 2.6.12-rc5:

> I applied your patch suggest by Herbert:
> 
> http://www.mail-archive.com/openib-general%40openib.org/msg11415.html
> 
  I backed out this patch out of a few other kernels and always see a
performance improvement.  This gets back ~50-60 MB/s of the 90-100 MB/s
drop off in IPoIB performance.   

  Is it still worth testing the TSO patches that Herbert suggested for
some of the 2.6.13-rc kernels?
 
  Thanks,

   - Matt



All benchmarks are with RHEL4 x86_64 with HCA FW v4.7.0
dual EM64T 3.2 GHz PCIe IB HCA (memfull)

Kernel           OpenIB    msi_x  netperf (MB/s)  
2.6.14-rc4      in-kernel    1     434  (backed out patch)
2.6.14-rc4      in-kernel    1     385 

2.6.13.2        svn3627      1     446  (backed out patch)
2.6.13.2        svn3627      1     386 
2.6.13.2        in-kernel    1     394 

2.6.12.5        in-kernel    1     464  (backed out patch)
2.6.12.5        in-kernel    1     402 

2.6.12-rc6      in-kernel    1     470  (backed out patch) 
2.6.12-rc6      in-kernel    1     407

2.6.12-rc5      in-kernel    1     474 (backed out patch)
2.6.12-rc5      in-kernel    1     405 


2.6.9-11.ELsmp  svn3513      1     425  (Woody's results, 3.6Ghz EM64T) 
