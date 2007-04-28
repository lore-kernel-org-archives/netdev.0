From: Bill Fink <billfink@mindspring.com>
Subject: Re: [ofa-general] Re: IPoIB forwarding
Date: Sat, 28 Apr 2007 02:51:17 -0400
Message-ID: <20070428025117.a3b1200a.billfink@mindspring.com>
References: <6.1.2.0.2.20070423160212.12db6400@mail.llnl.gov>
	<20070425124652.GG1624@mellanox.co.il>
	<6.1.2.0.2.20070426083410.1389d9e0@mail.llnl.gov>
	<20070426161409.GF15540@mellanox.co.il>
	<6.1.2.0.2.20070426095112.138e9a68@mail.llnl.gov>
	<20070426180618.GJ15540@mellanox.co.il>
	<6.1.2.0.2.20070427115435.13ea5ec0@mail.llnl.gov>
	<46325DF3.2050203@hp.com>
	<6.1.2.0.2.20070427152027.13fe46d0@mail.llnl.gov>
	<46327A07.1000404@hp.com>
	<6.1.2.0.2.20070427153952.13fc7d08@mail.llnl.gov>
	<4632894D.40705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bryan Lawver <lawver1@llnl.gov>,
	Development list <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	general@lists.openfabrics.org, Linux@lists.openfabrics.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <4632894D.40705@hp.com>
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

On Fri, 27 Apr 2007, Rick Jones wrote:

> Bryan Lawver wrote:
> > I had so much debugging turned on that it was not the "slowing of the 
> > traffic" but the "non-coelescencing" that was the remedy.  The NIC is a 
> > MyriCom NIC and these are easy options to set.
> 
> As chance would have it, I've played with some Myricom myri10ge NICs recently, 
> and even disabled large receive offload during some netperf tests :)  It is a 
> modprobe option.  Going back now to the driver source and the README I see :-)
> 
> 
> <excerpt>
> Troubleshooting
> ===============
> 
> Large Receive Offload (LRO) is enabled by default.  This will
> interfere with forwarding TCP traffic.  If you plan to forward TCP
> traffic (using the host with the Myri10GE NIC as a router or bridge),
> you must disable LRO.  To disable LRO, load the myri10ge driver
> with myri10ge_lro set to 0:
> 
>           # modprobe myri10ge myri10ge_lro=0
> 
> Alternatively, you can disable LRO at runtime by disabling
> receive checksum offloading via ethtool:
> 
>     # ethtool -K eth2 rx off
> 
> </excerpt>
> 
> rick jones

What version of the myri10ge driver is this?  With the 1.2.0 version
that comes with the 2.6.20.7 kernel, there is no myri10ge_lro module
parameter.

[root@lang2 ~]# modinfo myri10ge | grep -i lro
[root@lang2 ~]# 

And I've been testing IP forwarding using two Myricom 10-GigE NICs
without setting any special modprobe parameters.

						-Bill
