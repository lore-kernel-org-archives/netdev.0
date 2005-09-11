From: Marc Lehmann <schmorp@schmorp.de>
Subject: Re: Fw: masquerading failure for at least icmp and tcp+sack on amd64
Date: Sun, 11 Sep 2005 15:19:43 +0200
Message-ID: <20050911131943.GC9865@schmorp.de>
References: <20050907052057.09714a4c.akpm@osdl.org>
	<431EDF78.8060505@trash.net> <20050907205923.GA6567@schmorp.de>
	<431F5CD2.8020905@trash.net> <20050907215213.GB8222@schmorp.de>
	<432174EE.80306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <432174EE.80306@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 09, 2005 at 01:41:34PM +0200, Patrick McHardy <kaber@trash.net> wrote:
> > And ICMP, TCP etc. starts working again.
> > 
> > Thanks for the analysis and the hint, I guess that verifies that its hw
> > checksumming. (Weird that hw checksumming on the underlying device somehow
> > changes the ppp packets, but nevertheless).
> 
> I tried reproducing the problem without any luck. Its odd that its
> happening on both eth and ppp devices, if it was just ppp I would
> suspect some missing checksum update/invalidation in the ppp driver.

> What network driver are you using?

Happens with both skge and sk98.

> Please also send a list of loaded
> modules and iptables rules. Thanks.

   sch_htb                16448  2 
   sch_ingress             4420  2 
   nvidia               4378188  12 
   mga                    60096  0 
   drm                    76136  1 mga
   agpgart                29864  2 nvidia,drm
   sch_sfq                 5568  4 
   tun                     9664  1 
   powernow_k8             9616  0 
   processor              20432  1 powernow_k8
   sco                    12552  2 
   ztdummy                 3360  0 
   zaptel                197760  5 ztdummy
   crc_ccitt               2112  1 zaptel
   lirc_i2c               10180  1 
   lirc_dev               14336  1 lirc_i2c
   budget                 10240  0 
   s5h1420                 8900  1 budget
   l64781                  7236  1 budget
   ves1820                 5892  1 budget
   budget_core             8516  1 budget
   saa7146                15624  2 budget,budget_core
   ttpci_eeprom            2432  1 budget_core
   stv0299                11272  1 budget
   tda8083                 5764  1 budget
   ves1x93                 6404  1 budget
   dvb_core               82812  2 budget,budget_core
   parport_pc             39472  1 
   lp                     10880  0 
   parport                37964  2 parport_pc,lp
   tuner                  24096  0 
   ivtv                  202388  2 
   i2c_algo_bit            9032  1 ivtv
   videodev                9792  1 ivtv
   saa7115                13200  0 
   saa7127                11668  0 
   msp3400                27980  0 
   tveeprom               14560  0 
   v4l1_compat            12804  0 
   loop                   57688  4 
   w83627hf               32616  0 
   i2c_sensor              3136  1 w83627hf
   i2c_isa                 2624  0 
   i2c_core               19800  19 lirc_i2c,budget,s5h1420,l64781,ves1820,budget_core,ttpci_eeprom,stv0299,tda8083,ves1x93,tuner,i2c_algo_bit,saa7115,saa7127,msp3400,tveeprom,w83627hf,i2c_sensor,i2c_isa
   snd_seq_oss            33316  0 
   snd_seq_midi            7616  0 
   snd_seq_midi_event      7488  2 snd_seq_oss,snd_seq_midi
   snd_seq                55128  5 snd_seq_oss,snd_seq_midi,snd_seq_midi_event
   snd_via82xx            25280  2 
   snd_ac97_codec         88900  1 snd_via82xx
   snd_mpu401_uart         7040  1 snd_via82xx
   snd_rawmidi            24224  2 snd_seq_midi,snd_mpu401_uart
   snd_seq_device          7824  4 snd_seq_oss,snd_seq_midi,snd_seq,snd_rawmidi
   fcusb2                683148  3 
   capidrv                30168  1 
   isdn                  109160  2 capidrv
   capi                   16112  8 
   kernelcapi             48736  3 fcusb2,capidrv,capi
   rfcomm                 35952  8 
   l2cap                  24520  7 rfcomm
   hci_usb                14728  3 
   bluetooth              46404  8 sco,rfcomm,l2cap,hci_usb
   cls_u32                 7624  8 
   skge                   34256  0 
   ipt_hashlimit           8024  1 
   ipv6                  254848  22 
   ehci_hcd               31816  0 
   uhci_hcd               31968  0 
   capifs                  4880  2 capi
   nfsd                  107656  17 
   lockd                  64912  2 nfsd
   nfs_acl                 3136  1 nfsd
   sunrpc                142632  13 nfsd,lockd,nfs_acl

However, it happens with init=/bin/bash and loading the single iptables
rule I sent in the original report, for either eth0/1 or the ppp
interface. I can send you my 278 other rules if you want, but they have
had no effect on the problem here.

-- 
                The choice of a
      -----==-     _GNU_
      ----==-- _       generation     Marc Lehmann
      ---==---(_)__  __ ____  __      pcg@goof.com
      --==---/ / _ \/ // /\ \/ /      http://schmorp.de/
      -=====/_/_//_/\_,_/ /_/\_\      XX11-RIPE
