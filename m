From: Doug Chapman <doug.chapman@hp.com>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Thu, 31 May 2007 11:16:09 -0400
Message-ID: <1180624569.23536.7.camel@athlon>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net>
	<20070531010814.GA30709@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	auke-jan.h.kok@intel.com, doug.chapman@hp.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070531010814.GA30709@gondor.apana.org.au>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 2007-05-31 at 11:08 +1000, Herbert Xu wrote:
> On Wed, May 30, 2007 at 05:22:30PM -0400, Doug Chapman wrote:
> > 
> > but once again broken just yesterday by the following commit.  I have
> > backed just this commit out and verified I no longer panic.
> 
> Hmm, the only way I can see this happening is if the hardware signals
> an interrupt even though we've explicitly shut it off.  Does this patch
> help? If it does help, does it produce the warning in dmesg?
> 
> Thanks,


The patch does fix the panic.  Here are all the e1000 messages from
dmesg after a bootup.  Note that only eth0 is actually configured and
connected:


# dmesg | grep e1000
e1000: 0000:01:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f8
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
e1000: 0000:01:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f9
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
e1000: 0000:15:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c4
e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
e1000: 0000:15:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c5
e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
e1000: Unexpected interrupt icr=0x4
e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX


- Doug



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
