From: Rick Jones <rick.jones2@hp.com>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Fri, 24 Aug 2007 11:46:26 -0700
Message-ID: <46CF2782.6060006@hp.com>
References: <OFC19F468C.48FB78EE-ON6525733F.0016047F-6525733F.00170F48@in.ibm.com>	<20070821.212229.82050253.davem@davemloft.net>	<46CC6DD1.5020105@hp.com>	<20070822.132145.90824527.davem@davemloft.net>	<1187906650.4279.16.camel@localhost>	<1187907903.4279.28.camel@localhost>
	<46CE0BA1.60206@hp.com>
	<20070823231820.2ae52cc0.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, herbert@gondor.apana.org.au, gaagaan@gmail.com,
	Robert.Olsson@data.slu.se, mcarlson@broadcom.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	hadi@cyberus.ca, kaber@trash.net, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org,
	David Miller <davem@davemloft.net>, sri@us.ibm.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070823231820.2ae52cc0.billfink@mindspring.com>
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

Bill Fink wrote:
> On Thu, 23 Aug 2007, Rick Jones wrote:
> 
> 
>>jamal wrote:
>>
>>>[TSO already passed - iirc, it has been
>>>demostranted to really not add much to throughput (cant improve much
>>>over closeness to wire speed) but improve CPU utilization].
>>
>>In the one gig space sure, but in the 10 Gig space, TSO on/off does make a 
>>difference for throughput.
> 
> 
> Not too much.
> 
> TSO enabled:
> 
> [root@lang2 ~]# ethtool -k eth2
> Offload parameters for eth2:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: on
> 
> [root@lang2 ~]# nuttcp -w10m 192.168.88.16
> 11813.4375 MB /  10.00 sec = 9906.1644 Mbps 99 %TX 80 %RX
> 
> TSO disabled:
> 
> [root@lang2 ~]# ethtool -K eth2 tso off
> [root@lang2 ~]# ethtool -k eth2
> Offload parameters for eth2:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: off
> 
> [root@lang2 ~]# nuttcp -w10m 192.168.88.16
> 11818.2500 MB /  10.00 sec = 9910.0176 Mbps 100 %TX 78 %RX
> 
> Pretty negligible difference it seems.

Leaves one wondering how often more than one segment was sent to the card in the 
9000 byte case :)

rick jones
