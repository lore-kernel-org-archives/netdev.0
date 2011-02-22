From: Hans Nieser <hnsr@xs4all.nl>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Tue, 22 Feb 2011 18:33:27 +0100
Message-ID: <1298396007.23906.27.camel@krikkit>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-dAojteszKQwcCSRjEcdJ"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-dAojteszKQwcCSRjEcdJ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Francois Romieu wrote:
> Seblu <seblu@seblu.net> :
> [...]
> > I've applyed your patch on 2.6.38-rc5. Host have rebooted 2mn after udp start.
> > After this reboot, host is still on after 2 hour under a 1Gbit/s udp flow.
> 
> Thanks for testing.
> 
> > I attached a dmesg output before reboot. Do you need anything else?
> 
> Mostly :
> 1. .config
> 2. the size of the udp packets and the mtu
> 
> As an option :
> 3. a few seconds of 'vmstat 1' from the host under test
> 4. an 'ethtool -s eth0' from the host under test
> 5. /proc/interrupts from the host under test
> 6. lspci -tv 
> 
> Can you apply the two attached patches on top of the previous ones and
> give it a try ? The debug should not be too verbose if things are stationary
> enough.

With your patches applied to 2.6.38-rc6, I have gathered some of the
info you requested from Seblu as well, I hope it's helpful:

1: see attachment

2: I'm not sure how to check the size of the packets, but I'm just
fetching a (large) file over http/tcp, so I guess they are mostly of the
size of my MTU which is 1500 looking at ifconfig output

For the other vmstat/ethtool/interrupts output, I started the following
commands remotely via ssh a second or two before starting the download,
and the machine locked up a few seconds later:

# vmstat 1
# while true; do echo .; ethtool -S eth0; sleep 0.5; done
(I assume you actually meant the -S option to ethtool btw, -s seemed to
be a noop)
# while true; do echo .; cat /proc/interrupts; sleep 0.5; done

I've attached the outputs of the above commands

I also included dmesg output generated during the transfer (the actual
transfer starts at the 256~ printk timestamp I believe), the dmesg is
probably missing a second or so at the end before machine locked up


6:

-[0000:00]-+-00.0  Intel Corporation Core Processor DMI
           +-03.0-[01]--+-00.0  ATI Technologies Inc Cypress [Radeon HD 5800 Series]
           |            \-00.1  ATI Technologies Inc Cypress HDMI Audio [Radeon HD 5800 Series]
           +-08.0  Intel Corporation Core Processor System Management Registers
           +-08.1  Intel Corporation Core Processor Semaphore and Scratchpad Registers
           +-08.2  Intel Corporation Core Processor System Control and Status Registers
           +-08.3  Intel Corporation Core Processor Miscellaneous Registers
           +-10.0  Intel Corporation Core Processor QPI Link
           +-10.1  Intel Corporation Core Processor QPI Routing and Protocol Registers
           +-1a.0  Intel Corporation 5 Series/3400 Series Chipset USB Universal Host Controller
           +-1a.1  Intel Corporation 5 Series/3400 Series Chipset USB Universal Host Controller
           +-1a.2  Intel Corporation 5 Series/3400 Series Chipset USB Universal Host Controller
           +-1a.7  Intel Corporation 5 Series/3400 Series Chipset USB2 Enhanced Host Controller
           +-1b.0  Intel Corporation 5 Series/3400 Series Chipset High Definition Audio
           +-1c.0-[02]--+-00.0  JMicron Technology Corp. JMB362/JMB363 Serial ATA Controller
           |            \-00.1  JMicron Technology Corp. JMB362/JMB363 Serial ATA Controller
           +-1c.1-[03]----00.0  Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller
           +-1c.2-[04]----00.0  NEC Corporation Device 0194
           +-1d.0  Intel Corporation 5 Series/3400 Series Chipset USB Universal Host Controller
           +-1d.1  Intel Corporation 5 Series/3400 Series Chipset USB Universal Host Controller
           +-1d.2  Intel Corporation 5 Series/3400 Series Chipset USB Universal Host Controller
           +-1d.3  Intel Corporation 5 Series/3400 Series Chipset USB Universal Host Controller
           +-1d.7  Intel Corporation 5 Series/3400 Series Chipset USB2 Enhanced Host Controller
           +-1e.0-[05]----04.0  Texas Instruments TSB12LV23 IEEE-1394 Controller
           +-1f.0  Intel Corporation 5 Series Chipset LPC Interface Controller
           +-1f.2  Intel Corporation 5 Series/3400 Series Chipset 6 port SATA AHCI Controller
           \-1f.3  Intel Corporation 5 Series/3400 Series Chipset SMBus Controller



--=-dAojteszKQwcCSRjEcdJ
Content-Type: application/x-gzip; name="2.6.38-rc6-git-config.gz"
Content-Disposition: attachment; filename="2.6.38-rc6-git-config.gz"
Content-Transfer-Encoding: base64

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


--=-dAojteszKQwcCSRjEcdJ
Content-Disposition: attachment; filename="debug-dmesg"
Content-Type: text/plain; name="debug-dmesg"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

[    7.362642] Freeing unused kernel memory: 432k freed
[    9.800495] udev[1095]: starting version 164
[   12.317466] EXT3-fs (sda6): using internal journal
[   13.072807] EXT4-fs (sdb2): warning: maximal mount count reached, running e2fsck is recommended
[   13.073229] EXT4-fs (sdb2): mounted filesystem with ordered data mode. Opts: (null)
[   13.109537] EXT4-fs (sdb3): warning: maximal mount count reached, running e2fsck is recommended
[   13.125235] EXT4-fs (sdb3): mounted filesystem with ordered data mode. Opts: (null)
[   14.710943] Adding 4192928k swap on /dev/sda5.  Priority:-1 extents:1 across:4192928k 
[   15.764690] r8169 0000:03:00.0: eth0: link down
[   15.764695] 0020 0000 0000 0000
[   15.764702] r8169 0000:03:00.0: eth0: link down
[   15.765151] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   19.020958] 0020 0020 0000 0000
[   19.020970] r8169 0000:03:00.0: eth0: link up
[   19.021554] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   19.023429] 0020 0020 0084 0000
[   19.130371] 0020 0020 0084 0084
[   19.753752] 0084 0020 0084 0084
[   20.131392] 0084 0084 0084 0084
[   20.131480] 0084 0084 0001 0084
[   20.131508] 0084 0084 0001 0084
[   20.145422] 0001 0084 0001 0084
[   20.947682] net_ratelimit: 14 callbacks suppressed
[   20.947686] 0001 0084 0001 0084
[   20.961562] 0001 0084 0001 0084
[   21.566002] 0001 0084 0001 0084
[   21.946693] 0001 0084 0084 0084
[   21.956978] 0001 0084 0084 0001
[   22.945712] 0084 0084 0084 0001
[   22.954632] 0084 0001 0084 0001
[   22.957817] 0084 0001 0001 0001
[   23.944726] 0084 0001 0001 0084
[   23.955658] 0001 0001 0001 0084
[   26.397322] net_ratelimit: 4 callbacks suppressed
[   26.397324] 0001 0084 0084 0001
[   26.941849] 0001 0084 0084 0001
[   26.952315] 0001 0084 0084 0001
[   26.952516] CE: hpet4 increased min_delta_ns to 7500 nsec
[   26.952521] CE: hpet4 increased min_delta_ns to 11250 nsec
[   26.952544] CE: hpet3 increased min_delta_ns to 7500 nsec
[   26.952549] CE: hpet3 increased min_delta_ns to 11250 nsec
[   27.940861] 0084 0084 0084 0001
[   27.940878] 0084 0084 0084 0001
[   27.951797] 0084 0084 0001 0001
[   27.952032] 0084 0084 0001 0001
[   28.939867] 0004 0084 0001 0001
[   28.939870] 0004 0080 0001 0001
[   28.948839] 0004 0080 0001 0001
[   32.936012] net_ratelimit: 6 callbacks suppressed
[   32.936014] 0001 0084 0081 0001
[   32.945916] 0001 0084 0001 0001
[   34.934079] 0001 0084 0001 0084
[   34.942371] 0001 0084 0001 0084
[   37.810633] 0001 0001 0001 0084
[   37.812208] 0001 0001 0084 0084
[   37.812268] 0001 0001 0084 0001
[   37.812298] 0084 0001 0084 0001
[   37.812385] 0084 0001 0084 0001
[   37.815847] 0084 0001 0084 0001
[   37.951150] net_ratelimit: 17 callbacks suppressed
[   37.951152] 0084 0001 0084 0001
[   38.100181] 0084 0084 0084 0001
[   38.120969] 0084 0084 0001 0001
[   38.120998] 0084 0084 0001 0084
[   38.127134] 0084 0084 0001 0084
[   38.127817] 0084 0001 0001 0084
[   38.167842] 0084 0001 0084 0084
[   38.296883] 0084 0001 0084 0084
[   38.305463] 0001 0001 0084 0084
[   38.305746] 0001 0084 0084 0084
[   47.924331] net_ratelimit: 86 callbacks suppressed
[   47.924336] 0001 0001 0084 0001
[   47.924449] 0001 0001 0084 0001
[   47.927575] 0001 0001 0084 0001
[   47.927721] 0001 0001 0084 0001
[   48.116315] 0001 0001 0084 0001
[   48.118212] 0001 0084 0084 0001
[   48.118349] 0001 0084 0001 0001
[   48.120608] 0001 0084 0001 0084
[   48.120668] 0084 0084 0001 0084
[   48.120765] 0084 0001 0001 0084
[   61.863340] net_ratelimit: 52 callbacks suppressed
[   61.863344] 0001 0001 0001 0084
[   61.863373] 0001 0001 0001 0084
[   61.863500] 0001 0001 0001 0084
[   61.866560] 0001 0084 0001 0084
[   61.866630] 0001 0084 0001 0084
[   61.866890] 0001 0084 0001 0001
[   61.867048] 0084 0084 0001 0001
[   61.867533] 0084 0084 0001 0001
[   61.867582] 0084 0084 0001 0001
[   61.906994] 0084 0084 0001 0084
[   67.379512] net_ratelimit: 58 callbacks suppressed
[   67.379517] 0084 0001 0001 0084
[   67.742456] 0084 0001 0001 0001
[   67.745380] 0084 0001 0001 0001
[   67.786305] 0084 0001 0001 0001
[   68.117021] 0084 0001 0001 0001
[   68.120059] 0084 0001 0001 0084
[   68.120169] 0001 0001 0001 0084
[   68.309914] 0001 0001 0001 0084
[   68.311914] 0001 0001 0084 0084
[   68.311932] 0001 0001 0084 0001
[   73.466822] net_ratelimit: 35 callbacks suppressed
[   73.466827] 0001 0001 0001 0001
[   73.466861] 0084 0001 0001 0001
[   73.466982] 0084 0001 0001 0001
[   73.470317] 0084 0001 0084 0001
[   73.470379] 0084 0001 0084 0001
[   73.470663] 0001 0001 0084 0001
[   73.470827] 0001 0084 0084 0001
[   73.471316] 0001 0084 0084 0001
[   73.471337] 0001 0084 0084 0001
[   73.510796] 0084 0084 0084 0001
[   78.515173] net_ratelimit: 97 callbacks suppressed
[   78.515178] 0084 0001 0001 0001
[   78.515269] 0084 0001 0001 0084
[   78.515411] 0001 0001 0001 0084
[   78.642063] 0001 0001 0001 0084
[   78.643693] 0001 0001 0084 0084
[   78.643863] 0001 0001 0084 0001
[   78.666617] 0084 0001 0084 0001
[   78.666784] 0084 0001 0084 0001
[   78.667760] 0084 0001 0084 0001
[   78.668114] 0084 0001 0084 0001
[   83.997640] net_ratelimit: 40 callbacks suppressed
[   83.997644] 0001 0001 0084 0001
[   84.460476] 0001 0001 0084 0001
[   84.462195] 0001 0001 0084 0001
[   84.462433] 0001 0001 0084 0001
[   84.696262] 0001 0001 0084 0001
[   84.698921] 0001 0084 0084 0001
[   84.699251] 0001 0084 0001 0001
[   84.725252] 0001 0084 0001 0001
[   84.727891] 0084 0084 0001 0001
[   84.754215] 0084 0001 0001 0001
[   89.468722] net_ratelimit: 125 callbacks suppressed
[   89.468727] 0084 0001 0084 0001
[   89.471309] 0084 0001 0084 0001
[   89.499664] 0084 0001 0084 0001
[   89.502279] 0084 0001 0084 0001
[   89.527636] 0084 0001 0084 0001
[   89.530254] 0084 0001 0084 0001
[   89.555624] 0084 0001 0084 0001
[   89.557291] 0084 0001 0084 0001
[   89.585584] 0084 0001 0084 0001
[   89.588197] 0084 0001 0084 0001
[   95.393176] net_ratelimit: 30 callbacks suppressed
[   95.393181] 0001 0001 0084 0001
[   95.395565] 0084 0001 0084 0001
[   95.395901] 0084 0001 0084 0001
[   95.875207] 0084 0001 0084 0001
[   95.888142] 0084 0001 0084 0001
[   96.874263] 0084 0001 0084 0001
[   96.882576] 0084 0001 0084 0001
[   97.873300] 0084 0001 0084 0001
[   97.883204] 0084 0001 0084 0001
[   97.885801] 0001 0001 0084 0001
[  101.655799] 0001 0001 0084 0001
[  104.495510] 0001 0001 0001 0001
[  104.497779] 0001 0001 0001 0084
[  104.498115] 0001 0001 0001 0084
[  107.863176] 0001 0001 0001 0084
[  110.408705] 0001 0001 0001 0084
[  110.411139] 0001 0001 0001 0084
[  110.411278] 0001 0001 0001 0084
[  112.476458] 0001 0001 0001 0084
[  121.637630] 0001 0001 0001 0084
[  127.431241] 0001 0001 0001 0001
[  129.074757] 0001 0001 0001 0001
[  129.077067] 0001 0084 0001 0001
[  129.117642] 0001 0084 0001 0001
[  129.194754] 0001 0084 0001 0001
[  129.198026] 0084 0084 0001 0001
[  129.198126] 0084 0001 0001 0001
[  129.266678] 0084 0001 0001 0001
[  129.269954] 0084 0001 0001 0084
[  132.439479] net_ratelimit: 418 callbacks suppressed
[  132.439484] 0001 0084 0001 0084
[  132.439563] 0001 0084 0001 0084
[  132.441741] 0084 0084 0001 0084
[  132.444111] 0084 0004 0001 0084
[  132.444119] 0084 0004 0004 0084
[  132.444130] 0084 0004 0004 0084
[  132.444281] 0004 0004 0004 0084
[  132.444292] 0004 0004 0004 0084
[  132.444302] 0004 0004 0084 0084
[  132.444440] 0004 0004 0084 0001
[  137.530889] net_ratelimit: 118 callbacks suppressed
[  137.530894] 0084 0001 0001 0001
[  143.936457] 0084 0001 0001 0001
[  149.702560] 0001 0001 0001 0001
[  151.610378] 0001 0001 0001 0001
[  151.610410] 0001 0001 0084 0001
[  161.601436] 0001 0001 0084 0001
[  162.810531] 0084 0001 0084 0001
[  162.818457] 0084 0001 0084 0001
[  163.809576] 0084 0001 0084 0001
[  163.819093] 0084 0001 0084 0001
[  165.807641] 0084 0001 0084 0001
[  165.819746] 0084 0001 0084 0001
[  165.826577] 0084 0001 0001 0001
[  165.828636] 0084 0001 0001 0084
[  165.828747] 0001 0001 0001 0084
[  169.528058] net_ratelimit: 37 callbacks suppressed
[  169.528062] 0001 0001 0084 0084
[  169.528399] 0001 0001 0084 0001
[  169.949627] 0001 0001 0084 0001
[  169.953609] 0001 0084 0084 0001
[  169.953737] 0001 0084 0001 0001
[  169.989627] 0001 0084 0001 0001
[  169.992489] 0084 0084 0001 0001
[  170.033484] 0084 0001 0001 0001
[  170.621022] 0084 0001 0001 0001
[  170.621114] 0084 0001 0001 0084
[  175.207674] net_ratelimit: 28 callbacks suppressed
[  175.207678] 0001 0001 0084 0001
[  175.209525] 0001 0084 0084 0001
[  175.209648] 0001 0084 0001 0001
[  175.304530] 0001 0084 0001 0001
[  175.307443] 0084 0084 0001 0001
[  175.307573] 0084 0001 0001 0001
[  175.488392] 0084 0001 0001 0001
[  175.490060] 0084 0001 0001 0084
[  175.490135] 0001 0001 0001 0084
[  175.491155] 0001 0084 0001 0084
[  181.583322] net_ratelimit: 43 callbacks suppressed
[  181.583326] 0001 0001 0004 0080
[  183.413557] 0001 0001 0001 0080
[  183.414571] 0001 0001 0001 0084
[  183.454717] 0001 0001 0001 0084
[  183.470421] 0001 0001 0001 0084
[  183.471511] 0001 0001 0084 0084
[  183.471842] 0001 0001 0084 0001
[  183.525445] 0001 0001 0084 0001
[  183.526486] 0001 0084 0084 0001
[  183.526789] 0001 0084 0001 0001
[  191.574104] net_ratelimit: 25 callbacks suppressed
[  191.574109] 0001 0084 0001 0001
[  193.780628] 0001 0001 0001 0001
[  193.780660] 0001 0001 0084 0001
[  193.905505] 0001 0001 0084 0001
[  194.357981] 0001 0001 0084 0001
[  194.358019] 0001 0084 0084 0001
[  194.358114] 0001 0084 0001 0001
[  194.361314] 0001 0084 0001 0084
[  194.361368] 0001 0084 0001 0084
[  194.361519] 0001 0001 0001 0084
[  198.806025] net_ratelimit: 44 callbacks suppressed
[  198.806030] 0084 0001 0001 0001
[  198.806121] 0084 0001 0001 0084
[  198.806215] 0001 0001 0001 0084
[  199.085823] 0001 0001 0001 0084
[  199.085916] 0001 0001 0084 0084
[  199.086042] 0001 0001 0084 0001
[  199.150748] 0001 0001 0084 0001
[  199.150839] 0001 0084 0084 0001
[  199.150936] 0001 0084 0001 0001
[  199.397526] 0001 0084 0001 0001
[  203.823428] net_ratelimit: 46 callbacks suppressed
[  203.823432] 0084 0001 0001 0001
[  203.823806] 0084 0001 0001 0084
[  203.824129] 0001 0001 0001 0084
[  203.875381] 0001 0001 0001 0084
[  203.878773] 0001 0001 0001 0084
[  203.879824] 0001 0001 0001 0084
[  203.880166] 0001 0001 0001 0084
[  203.935719] 0001 0001 0001 0084
[  203.936733] 0001 0001 0084 0084
[  203.937087] 0001 0001 0084 0001
[  209.641493] net_ratelimit: 63 callbacks suppressed
[  209.641498] 0001 0084 0001 0001
[  211.555931] 0001 0084 0001 0001
[  211.555967] 0001 0084 0001 0001
[  220.007824] 0001 0084 0001 0001
[  220.008175] 0001 0084 0001 0001
[  221.546824] 0001 0084 0001 0001
[  222.532390] 0001 0001 0001 0001
[  222.534784] 0001 0001 0084 0001
[  222.534919] 0001 0001 0084 0001
[  222.629283] 0001 0001 0084 0001
[  222.630632] 0001 0084 0084 0001
[  222.630737] 0001 0084 0001 0001
[  222.708212] 0001 0084 0001 0001
[  225.609443] net_ratelimit: 90 callbacks suppressed
[  225.609447] 0001 0084 0001 0084
[  225.609723] 0001 0084 0001 0084
[  225.610782] 0084 0084 0001 0084
[  225.651247] 0084 0001 0001 0084
[  225.846189] 0084 0001 0001 0084
[  225.848584] 0084 0001 0001 0084
[  225.848876] 0001 0001 0001 0084
[  225.875187] 0001 0001 0001 0084
[  225.877592] 0001 0001 0084 0084
[  225.905157] 0001 0001 0084 0001
[  231.743925] net_ratelimit: 112 callbacks suppressed
[  231.743930] 0084 0001 0084 0001
[  231.756830] 0084 0001 0084 0001
[  232.354338] 0084 0001 0001 0001
[  234.741003] 0084 0001 0001 0084
[  234.753403] 0001 0001 0001 0084
[  239.743146] 0001 0084 0001 0084
[  239.743220] 0001 0084 0001 0084
[  241.528701] 0001 0084 0001 0001
[  247.531915] 0001 0084 0001 0001
[  251.519734] 0001 0001 0001 0001
[  253.844485] 0001 0001 0001 0001
[  253.962372] 0001 0001 0001 0001
[  253.964335] 0084 0001 0001 0001
[  253.964446] 0084 0001 0001 0001
[  253.965448] 0084 0001 0084 0001
[  253.965735] 0084 0001 0084 0001
[  254.492895] 0084 0001 0084 0001
[  254.492913] 0084 0001 0084 0001
[  256.649743] net_ratelimit: 46 callbacks suppressed
[  256.649748] 0084 0004 0080 0001
[  256.649818] 0084 0001 0080 0001
[  256.650744] 0084 0001 0084 0001
[  256.651019] 0084 0001 0084 0001
[  257.001333] 0084 0001 0084 0001
[  257.001431] 0084 0001 0084 0001
[  257.002568] 0084 0001 0084 0001
[  257.002839] 0084 0001 0084 0001
[  257.151255] 0084 0001 0084 0001
[  257.151377] 0084 0001 0084 0001
[  261.645823] net_ratelimit: 17905 callbacks suppressed
[  261.645828] 0001 0001 0084 0001
[  261.645862] 0084 0001 0084 0001
[  261.646133] 0084 0001 0084 0001
[  261.646171] 0084 0001 0084 0001
[  261.646336] 0084 0001 0084 0001
[  261.646423] 0001 0001 0084 0001
[  261.646460] 0001 0084 0084 0001
[  261.646627] 0001 0084 0001 0001
[  261.646799] 0001 0084 0001 0001
[  261.646818] 0084 0084 0001 0001


--=-dAojteszKQwcCSRjEcdJ
Content-Disposition: attachment; filename="interrupts"
Content-Type: text/plain; name="interrupts"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

# while true; do echo .; cat /proc/interrupts; sleep 0.5; done
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     253857          0          0          0  HPET_MSI-edge      hpet2
  41:          0     253814          0          0  HPET_MSI-edge      hpet3
  42:          0          0     253746          0  HPET_MSI-edge      hpet4
  43:          0          0          0     253646  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5847          0          0          0   PCI-MSI-edge      ahci
  47:          0       1822          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     254388          0          0          0  HPET_MSI-edge      hpet2
  41:          0     254343          0          0  HPET_MSI-edge      hpet3
  42:          0          0     254275          0  HPET_MSI-edge      hpet4
  43:          0          0          0     254175  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5850          0          0          0   PCI-MSI-edge      ahci
  47:          0       1828          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     254891          0          0          0  HPET_MSI-edge      hpet2
  41:          0     254845          0          0  HPET_MSI-edge      hpet3
  42:          0          0     254777          0  HPET_MSI-edge      hpet4
  43:          0          0          0     254677  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5862          0          0          0   PCI-MSI-edge      ahci
  47:          0       1835          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
  TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     255394          0          0          0  HPET_MSI-edge      hpet2
  41:          0     255348          0          0  HPET_MSI-edge      hpet3
  42:          0          0     255280          0  HPET_MSI-edge      hpet4
  43:          0          0          0     255181  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5864          0          0          0   PCI-MSI-edge      ahci
  47:          0       1847          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     255896          0          0          0  HPET_MSI-edge      hpet2
  41:          0     255850          0          0  HPET_MSI-edge      hpet3
  42:          0          0     255784          0  HPET_MSI-edge      hpet4
  43:          0          0          0     255683  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5876          0          0          0   PCI-MSI-edge      ahci
  47:          0       1857          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     256399          0          0          0  HPET_MSI-edge      hpet2
  41:          0     256352          0          0  HPET_MSI-edge      hpet3
  42:          0          0     256287          0  HPET_MSI-edge      hpet4
  43:          0          0          0     256185  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5876          0          0          0   PCI-MSI-edge      ahci
  47:          0       1868          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     256901          0          0          0  HPET_MSI-edge      hpet2
  41:          0     256854          0          0  HPET_MSI-edge      hpet3
  42:          0          0     256791          0  HPET_MSI-edge      hpet4
  43:          0          0          0     256687  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5876          0          0          0   PCI-MSI-edge      ahci
  47:          0       1877          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     257404          0          0          0  HPET_MSI-edge      hpet2
  41:          0     257356          0          0  HPET_MSI-edge      hpet3
  42:          0          0     257294          0  HPET_MSI-edge      hpet4
  43:          0          0          0     257190  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5890          0          0          0   PCI-MSI-edge      ahci
  47:          0       2067          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     257906          0          0          0  HPET_MSI-edge      hpet2
  41:          0     257859          0          0  HPET_MSI-edge      hpet3
  42:          0          0     257797          0  HPET_MSI-edge      hpet4
  43:          0          0          0     257692  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5902          0          0          0   PCI-MSI-edge      ahci
  47:          0       4019          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     258409          0          0          0  HPET_MSI-edge      hpet2
  41:          0     258361          0          0  HPET_MSI-edge      hpet3
  42:          0          0     258300          0  HPET_MSI-edge      hpet4
  43:          0          0          0     258195  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5902          0          0          0   PCI-MSI-edge      ahci
  47:          0       6806          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     258911          0          0          0  HPET_MSI-edge      hpet2
  41:          0     258863          0          0  HPET_MSI-edge      hpet3
  42:          0          0     258803          0  HPET_MSI-edge      hpet4
  43:          0          0          0     258698  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5902          0          0          0   PCI-MSI-edge      ahci
  47:          0       9302          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     259413          0          0          0  HPET_MSI-edge      hpet2
  41:          0     259365          0          0  HPET_MSI-edge      hpet3
  42:          0          0     259307          0  HPET_MSI-edge      hpet4
  43:          0          0          0     259201  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5902          0          0          0   PCI-MSI-edge      ahci
  47:          0      12494          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     259916          0          0          0  HPET_MSI-edge      hpet2
  41:          0     259868          0          0  HPET_MSI-edge      hpet3
  42:          0          0     259811          0  HPET_MSI-edge      hpet4
  43:          0          0          0     259704  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5919          0          0          0   PCI-MSI-edge      ahci
  47:          0      13625          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        115          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     260419          0          0          0  HPET_MSI-edge      hpet2
  41:          0     260370          0          0  HPET_MSI-edge      hpet3
  42:          0          0     260314          0  HPET_MSI-edge      hpet4
  43:          0          0          0     260207  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5919          0          0          0   PCI-MSI-edge      ahci
  47:          0      13748          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        116          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     260921          0          0          0  HPET_MSI-edge      hpet2
  41:          0     260872          0          0  HPET_MSI-edge      hpet3
  42:          0          0     260816          0  HPET_MSI-edge      hpet4
  43:          0          0          0     260711  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5919          0          0          0   PCI-MSI-edge      ahci
  47:          0      15062          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        116          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     261424          0          0          0  HPET_MSI-edge      hpet2
  41:          0     261375          0          0  HPET_MSI-edge      hpet3
  42:          0          0     261320          0  HPET_MSI-edge      hpet4
  43:          0          0          0     261214  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5919          0          0          0   PCI-MSI-edge      ahci
  47:          0      17204          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        116          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0
.
            CPU0       CPU1       CPU2       CPU3       
   0:        116          0          0          1   IO-APIC-edge      timer
   1:          0          0          0          2   IO-APIC-edge      i8042
   4:          0          0          0          2   IO-APIC-edge    
   8:          0          0          0         81   IO-APIC-edge      rtc0
   9:          0          0          0          0   IO-APIC-fasteoi   acpi
  16:          0          0          0          0   IO-APIC-fasteoi   ahci, uhci_hcd:usb3, uhci_hcd:usb9
  17:          0          0          0          0   IO-APIC-fasteoi   pata_jmicron
  18:          0          0          0        269   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb5, uhci_hcd:usb8
  19:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb7
  21:          0          0          0          0   IO-APIC-fasteoi   uhci_hcd:usb4
  23:          0          0          0          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb6
  40:     261926          0          0          0  HPET_MSI-edge      hpet2
  41:          0     261877          0          0  HPET_MSI-edge      hpet3
  42:          0          0     261824          0  HPET_MSI-edge      hpet4
  43:          0          0          0     261716  HPET_MSI-edge      hpet5
  45:          0          0          0        611   PCI-MSI-edge      radeon
  46:       5931          0          0          0   PCI-MSI-edge      ahci
  47:          0      20063          0          0   PCI-MSI-edge      eth0
  48:          0          0          1          0   PCI-MSI-edge      xhci_hcd
  49:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  50:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  51:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  52:          0          0          0          0   PCI-MSI-edge      xhci_hcd
  53:          0        196          0          0   PCI-MSI-edge      hda_intel
  54:          0          0         28          0   PCI-MSI-edge      hda_intel
 NMI:          0          0          0          0   Non-maskable interrupts
 LOC:        268        229        137         45   Local timer interrupts
 SPU:          0          0          0          0   Spurious interrupts
 PMI:          0          0          0          0   Performance monitoring interrupts
 IWI:          0          0          0          0   IRQ work interrupts
 RES:         70         43         38         32   Rescheduling interrupts
 CAL:         29         60         51         52   Function call interrupts
 TLB:        212        169        116          9   TLB shootdowns
 TRM:          0          0          0          0   Thermal event interrupts
 THR:          0          0          0          0   Threshold APIC interrupts
 MCE:          0          0          0          0   Machine check exceptions
 MCP:          2          2          2          2   Machine check polls
 ERR:          3
 MIS:          0


--=-dAojteszKQwcCSRjEcdJ
Content-Disposition: attachment; filename="ethtool-stats"
Content-Type: text/plain; name="ethtool-stats"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

# while true; do echo .; ethtool -S eth0; sleep 0.5; done
.
NIC statistics:
     tx_packets: 1068
     rx_packets: 879
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 822
     broadcast: 56
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 1073
     rx_packets: 882
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 825
     broadcast: 56
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 1081
     rx_packets: 889
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 832
     broadcast: 56
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 1086
     rx_packets: 892
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 835
     broadcast: 56
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 1094
     rx_packets: 898
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 841
     broadcast: 56
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 1100
     rx_packets: 902
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 845
     broadcast: 56
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 1397
     rx_packets: 2086
     tx_errors: 0
     rx_errors: 0
     rx_missed: 8
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 2028
     broadcast: 57
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 2434
     rx_packets: 6544
     tx_errors: 0
     rx_errors: 0
     rx_missed: 34
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 6486
     broadcast: 57
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 4361
     rx_packets: 14479
     tx_errors: 0
     rx_errors: 0
     rx_missed: 80
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 14421
     broadcast: 57
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 5853
     rx_packets: 20659
     tx_errors: 0
     rx_errors: 0
     rx_missed: 113
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 20601
     broadcast: 57
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 7485
     rx_packets: 28008
     tx_errors: 0
     rx_errors: 0
     rx_missed: 151
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 27950
     broadcast: 57
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 7787
     rx_packets: 29253
     tx_errors: 0
     rx_errors: 0
     rx_missed: 161
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 29195
     broadcast: 57
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 8031
     rx_packets: 29904
     tx_errors: 0
     rx_errors: 0
     rx_missed: 170
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 29846
     broadcast: 57
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 9031
     rx_packets: 34321
     tx_errors: 0
     rx_errors: 0
     rx_missed: 186
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 34263
     broadcast: 57
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 10261
     rx_packets: 39805
     tx_errors: 0
     rx_errors: 0
     rx_missed: 221
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 39747
     broadcast: 57
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0
.
NIC statistics:
     tx_packets: 10261
     rx_packets: 39805
     tx_errors: 0
     rx_errors: 0
     rx_missed: 221
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 39747
     broadcast: 57
     multicast: 1
     tx_aborted: 0
     tx_underrun: 0



--=-dAojteszKQwcCSRjEcdJ
Content-Disposition: attachment; filename="vmstat"
Content-Type: text/plain; name="vmstat"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

# vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0      0 8066536   4876  28220    0    0    65     3 1010   45  0  0 98  1
 0  0      0 8066536   4876  28188    0    0     0     0 4036  144  0  0 100  0
 0  0      0 8065040   4892  28428    0    0   388     0 4051  194  0  0 99  1
 0  0      0 8049916   4892  42896    0    0     0     0 8419 3320  0  5 95  0
 0  0      0 8030112   4892  62188    0    0     0     0 9749 4420  0  7 93  0
 0  0      0 8024664   4900  67920    0    0     0    24 5659 1356  0  2 98  0
 0  0      0 8014876   4900  77140    0    0     0     0 6953 2442  0  4 96  0


--=-dAojteszKQwcCSRjEcdJ--
