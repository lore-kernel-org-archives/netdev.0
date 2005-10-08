From: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
Subject: Re: Timeline of IPoIB performance
Date: Fri, 07 Oct 2005 19:25:49 -0700
Message-ID: <1128738350.13945.369.camel@localhost>
References: <1128672413.13948.326.camel@localhost> <52br20lsei.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rolandd@cisco.com>
In-Reply-To: <52br20lsei.fsf@cisco.com>
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

I'm adding netdev to this thread to see if they can help.

I'm seeing an IPoIB (IP over InfiniBand) netperf performance drop off,
of up to 90 MB/s, when using kernels newer than 2.6.11.  This doesn't
appear to be an OpenIB IPoIB issue since the older in-kernel IB for
2.6.11 and a recent svn3687 snapshot both have the same performance (464
MB/s) with 2.6.11.  I used the same kernel config file as a starting
point for each of these kernel builds.  Have there been any changes in
Linux that would explain these results?

Here is the hardware setup and netperf results using 'netperf -f -M -c
-C -H IPoIB_ADDRESS

All benchmarks are with RHEL4 x86_64 with HCA FW v4.7.0
dual EM64T 3.2 GHz PCIe IB HCA (memfull)

Kernel           OpenIB    msi_x  netperf (MB/s)  
2.6.14-rc3      in-kernel    1     374 
2.6.13.2        svn3627      1     386 
2.6.13.2        in-kernel    1     394 
2.6.12.5-lustre in-kernel    1     399  
2.6.12.5        in-kernel    1     402 
2.6.12          in-kernel    1     406 
2.6.12-rc6      in-kernel    1     407
2.6.12-rc5      in-kernel    1     405   <<<<<
2.6.12-rc4      in-kernel    1     470   <<<<<
2.6.12-rc3      in-kernel    1     466 
2.6.12-rc2      in-kernel    1     469 
2.6.12-rc1      in-kernel    1     466
2.6.11          in-kernel    1     464 
2.6.11          svn3687      1     464 
2.6.9-11.ELsmp  svn3513      1     425  (Woody's results, 3.6Ghz EM64T) 

 Thanks,

	- Matt
