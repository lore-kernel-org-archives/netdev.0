From: Mason <slash.tmp@free.fr>
Subject: Ethernet not working on a different SoC with same eth HW
Date: Mon, 31 Oct 2016 16:29:25 +0100
Message-ID: <58176355.7090200@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Mans Rullgard <mans@mansr.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>,
        Sebastian Frias <sf84@laposte.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:7201 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S944018AbcJaP35 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 11:29:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

I'm using these net drivers:

  drivers/net/ethernet/aurora/nb8800.c
  drivers/net/phy/at803x.c

With a smp8758 board, they work great.
I've been trying to use them on a different board:

  same eth PHY (Atheros AR8035)
  same eth MAC (Aurora SSN8800)
  different SoC (same base address for MAC block)

It doesn't work, and I'm not sure where to look first...
I put logs in some functions to get a rough idea.
When the kernel boots, it prints:

[    0.798912] libphy: mdiobus_read: addr=0 regnum=00000002 from get_phy_device
[    0.806515] libphy: mdiobus_read: addr=0 regnum=00000003 from get_phy_device
[    0.813704] libphy: mdiobus_read: addr=1 regnum=00000002 from get_phy_device
[    0.820923] libphy: mdiobus_read: addr=1 regnum=00000003 from get_phy_device
[    0.828192] libphy: mdiobus_read: addr=2 regnum=00000002 from get_phy_device
[    0.835373] libphy: mdiobus_read: addr=2 regnum=00000003 from get_phy_device
[    0.842547] libphy: mdiobus_read: addr=3 regnum=00000002 from get_phy_device
[    0.849681] libphy: mdiobus_read: addr=3 regnum=00000003 from get_phy_device
[    0.856814] libphy: mdiobus_read: addr=4 regnum=00000002 from get_phy_device
[    0.863944] libphy: mdiobus_read: addr=4 regnum=00000003 from get_phy_device
[    0.871075] libphy: mdiobus_read: addr=5 regnum=00000002 from get_phy_device
[    0.878202] libphy: mdiobus_read: addr=5 regnum=00000003 from get_phy_device
[    0.885331] libphy: mdiobus_read: addr=6 regnum=00000002 from get_phy_device
[    0.892458] libphy: mdiobus_read: addr=6 regnum=00000003 from get_phy_device
[    0.899586] libphy: mdiobus_read: addr=7 regnum=00000002 from get_phy_device
[    0.906715] libphy: mdiobus_read: addr=7 regnum=00000003 from get_phy_device
[    0.913844] libphy: mdiobus_read: addr=8 regnum=00000002 from get_phy_device
[    0.920972] libphy: mdiobus_read: addr=8 regnum=00000003 from get_phy_device
[    0.928101] libphy: mdiobus_read: addr=9 regnum=00000002 from get_phy_device
[    0.935230] libphy: mdiobus_read: addr=9 regnum=00000003 from get_phy_device
[    0.942359] libphy: mdiobus_read: addr=10 regnum=00000002 from get_phy_device
[    0.949576] libphy: mdiobus_read: addr=10 regnum=00000003 from get_phy_device
[    0.956793] libphy: mdiobus_read: addr=11 regnum=00000002 from get_phy_device
[    0.964009] libphy: mdiobus_read: addr=11 regnum=00000003 from get_phy_device
[    0.971225] libphy: mdiobus_read: addr=12 regnum=00000002 from get_phy_device
[    0.978441] libphy: mdiobus_read: addr=12 regnum=00000003 from get_phy_device
[    0.985657] libphy: mdiobus_read: addr=13 regnum=00000002 from get_phy_device
[    0.992873] libphy: mdiobus_read: addr=13 regnum=00000003 from get_phy_device
[    1.000089] libphy: mdiobus_read: addr=14 regnum=00000002 from get_phy_device
[    1.007305] libphy: mdiobus_read: addr=14 regnum=00000003 from get_phy_device
[    1.014522] libphy: mdiobus_read: addr=15 regnum=00000002 from get_phy_device
[    1.021737] libphy: mdiobus_read: addr=15 regnum=00000003 from get_phy_device
[    1.028953] libphy: mdiobus_read: addr=16 regnum=00000002 from get_phy_device
[    1.036169] libphy: mdiobus_read: addr=16 regnum=00000003 from get_phy_device
[    1.043385] libphy: mdiobus_read: addr=17 regnum=00000002 from get_phy_device
[    1.050600] libphy: mdiobus_read: addr=17 regnum=00000003 from get_phy_device
[    1.057817] libphy: mdiobus_read: addr=18 regnum=00000002 from get_phy_device
[    1.065032] libphy: mdiobus_read: addr=18 regnum=00000003 from get_phy_device
[    1.072250] libphy: mdiobus_read: addr=19 regnum=00000002 from get_phy_device
[    1.079464] libphy: mdiobus_read: addr=19 regnum=00000003 from get_phy_device
[    1.086679] libphy: mdiobus_read: addr=20 regnum=00000002 from get_phy_device
[    1.093895] libphy: mdiobus_read: addr=20 regnum=00000003 from get_phy_device
[    1.101111] libphy: mdiobus_read: addr=21 regnum=00000002 from get_phy_device
[    1.108327] libphy: mdiobus_read: addr=21 regnum=00000003 from get_phy_device
[    1.115542] libphy: mdiobus_read: addr=22 regnum=00000002 from get_phy_device
[    1.122757] libphy: mdiobus_read: addr=22 regnum=00000003 from get_phy_device
[    1.129973] libphy: mdiobus_read: addr=23 regnum=00000002 from get_phy_device
[    1.137189] libphy: mdiobus_read: addr=23 regnum=00000003 from get_phy_device
[    1.144405] libphy: mdiobus_read: addr=24 regnum=00000002 from get_phy_device
[    1.151620] libphy: mdiobus_read: addr=24 regnum=00000003 from get_phy_device
[    1.158835] libphy: mdiobus_read: addr=25 regnum=00000002 from get_phy_device
[    1.166050] libphy: mdiobus_read: addr=25 regnum=00000003 from get_phy_device
[    1.173266] libphy: mdiobus_read: addr=26 regnum=00000002 from get_phy_device
[    1.180481] libphy: mdiobus_read: addr=26 regnum=00000003 from get_phy_device
[    1.187697] libphy: mdiobus_read: addr=27 regnum=00000002 from get_phy_device
[    1.194911] libphy: mdiobus_read: addr=27 regnum=00000003 from get_phy_device
[    1.202127] libphy: mdiobus_read: addr=28 regnum=00000002 from get_phy_device
[    1.209341] libphy: mdiobus_read: addr=28 regnum=00000003 from get_phy_device
[    1.216557] libphy: mdiobus_read: addr=29 regnum=00000002 from get_phy_device
[    1.223771] libphy: mdiobus_read: addr=29 regnum=00000003 from get_phy_device
[    1.230987] libphy: mdiobus_read: addr=30 regnum=00000002 from get_phy_device
[    1.238203] libphy: mdiobus_read: addr=30 regnum=00000003 from get_phy_device
[    1.245419] libphy: mdiobus_read: addr=31 regnum=00000002 from get_phy_device
[    1.252635] libphy: mdiobus_read: addr=31 regnum=00000003 from get_phy_device
[    1.259840] libphy: Fixed MDIO Bus: probed
[    1.264606] [drivers/net/ethernet/aurora/nb8800.c:1455] nb8800_probe(): mark
[    1.272006] [drivers/net/ethernet/aurora/nb8800.c:1461] nb8800_probe(): mark
[    1.279218] [drivers/net/ethernet/aurora/nb8800.c:1469] nb8800_probe(): mark: 21
[    1.286799] [drivers/net/ethernet/aurora/nb8800.c:1379] nb8800_tangox_reset(): mark
[    1.294669] ++ETH w8 [f0026424] 00 from nb8800_probe
[    1.309789] ++ETH w8 [f0026424] 01 from nb8800_probe
[    1.314831] ++ETH w16 [f0026420] 0050 from nb8800_probe
[    1.320343] libphy: nb8800-mii: probed
[    1.324352] libphy: 1: [drivers/net/phy/phy_device.c:357] phy_device_create(): mark: cf9a89c0, -1, -1
[    1.342087] libphy: 1: [drivers/net/phy/phy_device.c:1601] phy_probe(): mark: -1, 1, 0
[    1.350406] libphy: 1: [drivers/net/phy/phy_device.c:1610] phy_probe(): mark: -1
[    1.357990] ++ETH w8 [f0026000] 1c from platform_drv_probe
[    1.363591] ++ETH w8 [f0026001] 05 from platform_drv_probe
[    1.369203] ++ETH w8 [f0026004] 22 from platform_drv_probe
[    1.374799] ++ETH w8 [f0026008] 04 from platform_drv_probe
[    1.380390] ++ETH w8 [f0026014] 0c from platform_drv_probe
[    1.385947] ++ETH w8 [f0026051] 00 from platform_drv_probe
[    1.391500] ++ETH w8 [f0026052] ff from platform_drv_probe
[    1.397051] ++ETH w8 [f0026054] 40 from platform_drv_probe
[    1.402602] ++ETH r32 [f0026100] 00000008 from platform_drv_probe
[    1.408767] ++ETH w32 [f0026100] 000002fe from platform_drv_probe
[    1.414933] ++ETH w32 [f0026118] 003cc4a4 from platform_drv_probe
[    1.421196] ++ETH r32 [f0026200] 00000008 from platform_drv_probe
[    1.427367] ++ETH w32 [f0026200] 000002fe from platform_drv_probe
[    1.433535] ++ETH w32 [f0026218] 00004dc8 from platform_drv_probe
[    1.439699] ++ETH w8 [f0026060] 00 from platform_drv_probe
[    1.445252] ++ETH w8 [f0026061] c3 from platform_drv_probe
[    1.450806] ++ETH w8 [f002602e] 00 from nb8800_probe
[    1.455832] [drivers/net/ethernet/aurora/nb8800.c:1403] nb8800_tango4_init(): mark
[    1.463476] [drivers/net/ethernet/aurora/nb8800.c:1347] nb8800_tangox_init(): mark
[    1.471127] ++ETH w8 [f0026400] 01 from nb8800_tango4_init
[    1.476679] ++ETH r32 [f0026200] 000002fe from nb8800_probe
[    1.482317] ++ETH w32 [f0026200] 0000028e from nb8800_probe
[    1.487961] ++ETH w8 [f002606a] 00 from nb8800_probe
[    1.492988] ++ETH w8 [f002606b] 16 from nb8800_probe
[    1.498015] ++ETH w8 [f002606c] e8 from nb8800_probe
[    1.503039] ++ETH w8 [f002606d] 46 from nb8800_probe
[    1.508063] ++ETH w8 [f002606e] 98 from nb8800_probe
[    1.513088] ++ETH w8 [f002606f] 50 from nb8800_probe
[    1.518114] ++ETH w8 [f002603c] 00 from nb8800_probe
[    1.523140] ++ETH w8 [f002603d] 16 from nb8800_probe
[    1.528165] ++ETH w8 [f002603e] e8 from nb8800_probe
[    1.533190] ++ETH w8 [f002603f] 46 from nb8800_probe
[    1.538216] ++ETH w8 [f0026040] 98 from nb8800_probe
[    1.543241] ++ETH w8 [f0026041] 50 from nb8800_probe
[    1.549468] nb8800 26000.ethernet eth0: MAC address 00:16:e8:46:98:50

which looks alright, I suppose.

Then I configure the address, and set link up:

ip addr add 10.10.7.81/24 dev eth0
ip link set eth0 up


[  224.524920] [drivers/net/ethernet/aurora/nb8800.c:1011] nb8800_open(): mark
[  224.532055] ++ETH w32 [f0026204] 0000000f from __dev_open
[  224.538052] ++ETH w32 [f0026104] 0000000f from __dev_open
[  224.545223] ++ETH w32 [f002620c] 8fbfa000 from nb8800_open
[  224.550933] ++ETH r8 [f0026004] 22 from nb8800_open
[  224.556175] ++ETH w8 [f0026004] 23 from nb8800_open
[  224.561316] ++ETH r32 [f0026100] 000002fe from nb8800_open
[  224.567062] ++ETH r8 [f0026000] 1c from nb8800_open
[  224.572194] ++ETH w8 [f0026000] 1d from nb8800_open
[  224.577327] libphy: 1: [drivers/net/phy/phy_device.c:694] phy_connect_direct(): mark
[  224.585345] libphy: 1: [drivers/net/phy/phy_device.c:1420] genphy_soft_reset(): mark
[  224.593368] ++ETH w32 [f0026020] 04808000 from nb8800_mdio_write
[  224.599650] ++ETH w32 [f0026020] 84808000 from nb8800_mdio_write
[  224.605954] libphy: 1: [drivers/net/phy/phy_device.c:792] phy_poll_reset(): mark
[  224.664206] libphy: mdiobus_read: addr=4 regnum=00000000 from genphy_soft_reset
[  224.671606] nb8800_mdio_read from mdiobus_read
[  224.676394] ++ETH w32 [f0026020] 00800000 from nb8800_mdio_read
[  224.682589] ++ETH w32 [f0026020] 80800000 from nb8800_mdio_read
[  224.688812] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  224.700863] 1: [drivers/net/phy/at803x.c:311] at803x_config_init(): mark
[  224.707647] libphy: 1: [drivers/net/phy/phy_device.c:1435] genphy_config_init(): mark
[  224.715847] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_config_init
[  224.723515] nb8800_mdio_read from mdiobus_read
[  224.728216] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  224.734412] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  224.740633] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  224.746472] libphy: mdiobus_read: addr=4 regnum=0000000f from genphy_config_init
[  224.754137] nb8800_mdio_read from mdiobus_read
[  224.758836] ++ETH w32 [f0026020] 008f0000 from nb8800_mdio_read
[  224.765033] ++ETH w32 [f0026020] 808f0000 from nb8800_mdio_read
[  224.771255] ++ETH r32 [f0026024] 0000a000 from mdiobus_read
[  224.777088] libphy: mdiobus_read: addr=4 regnum=00000000 from at803x_resume
[  224.784338] nb8800_mdio_read from mdiobus_read
[  224.789035] ++ETH w32 [f0026020] 00800000 from nb8800_mdio_read
[  224.795226] ++ETH w32 [f0026020] 80800000 from nb8800_mdio_read
[  224.801448] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  224.807281] ++ETH w32 [f0026020] 04800000 from nb8800_mdio_write
[  224.813561] ++ETH w32 [f0026020] 84800000 from nb8800_mdio_write
[  224.819865] libphy: 1: [drivers/net/phy/phy.c:625] phy_start_machine(): mark
[  224.827208] libphy: 1: [drivers/net/phy/phy.c:942] phy_state_machine(): mark: 0, 2
[  224.835055] ++ETH r32 [f0026200] 0000028e from nb8800_open
[  224.835069] ++ETH w32 [f0026200] 0000028f from nb8800_open
[  224.835086] ++ETH r8 [f0026004] 23 from nb8800_set_rx_mode
[  224.835098] ++ETH w8 [f002602e] 00 from nb8800_set_rx_mode
[  224.835173] ++ETH r8 [f0026004] 23 from nb8800_set_rx_mode
[  224.835185] ++ETH w8 [f002602e] 00 from nb8800_set_rx_mode
[  224.835207] ++ETH w8 [f0026028] 01 from __dev_set_rx_mode
[  224.835221] ++ETH w8 [f0026029] 00 from __dev_set_rx_mode
[  224.835234] ++ETH w8 [f002602a] 5e from __dev_set_rx_mode
[  224.835247] ++ETH w8 [f002602b] 00 from __dev_set_rx_mode
[  224.835259] ++ETH w8 [f002602c] 00 from __dev_set_rx_mode
[  224.835272] ++ETH w8 [f002602d] 01 from __dev_set_rx_mode
[  224.835284] ++ETH w8 [f002602e] ff from nb8800_set_rx_mode
[  224.909895] libphy: 1: [drivers/net/phy/phy_device.c:1195] genphy_config_aneg(): mark
[  224.919140] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_config_aneg
[  224.926818] nb8800_mdio_read from mdiobus_read
[  224.931540] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  224.937738] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  224.943960] ++ETH r32 [f0026024] 000011e1 from mdiobus_read
[  224.949795] ++ETH w32 [f0026020] 048415e1 from nb8800_mdio_write
[  224.956077] ++ETH w32 [f0026020] 848415e1 from nb8800_mdio_write
[  224.962396] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_config_aneg
[  224.970060] nb8800_mdio_read from mdiobus_read
[  224.974758] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  224.980981] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  224.987204] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  224.993041] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_config_aneg
[  225.000706] nb8800_mdio_read from mdiobus_read
[  225.005404] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  225.011597] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  225.017822] ++ETH r32 [f0026024] 00000300 from mdiobus_read
[  225.023655] ++ETH w32 [f0026020] 04890200 from nb8800_mdio_write
[  225.029934] ++ETH w32 [f0026020] 84890200 from nb8800_mdio_write
[  225.036250] libphy: mdiobus_read: addr=4 regnum=00000000 from genphy_restart_aneg
[  225.044002] nb8800_mdio_read from mdiobus_read
[  225.048700] ++ETH w32 [f0026020] 00800000 from nb8800_mdio_read
[  225.054892] ++ETH w32 [f0026020] 80800000 from nb8800_mdio_read
[  225.061113] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.066948] ++ETH w32 [f0026020] 04801200 from nb8800_mdio_write
[  225.073301] ++ETH w32 [f0026020] 84801200 from nb8800_mdio_write
[  225.079656] libphy: 1: [drivers/net/phy/phy.c:942] phy_state_machine(): mark: 0, 5
[  225.087602] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  225.095270] nb8800_mdio_read from mdiobus_read
[  225.099969] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  225.106164] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  225.112385] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  225.118223] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  225.125887] nb8800_mdio_read from mdiobus_read
[  225.130584] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  225.136776] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  225.142997] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  225.148837] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  225.156504] nb8800_mdio_read from mdiobus_read
[  225.161220] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  225.167412] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  225.173633] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.179471] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  225.187135] nb8800_mdio_read from mdiobus_read
[  225.191833] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  225.198025] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  225.204279] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  225.210116] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  225.217781] nb8800_mdio_read from mdiobus_read
[  225.222478] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  225.228673] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  225.234893] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.240731] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  225.248396] nb8800_mdio_read from mdiobus_read
[  225.253093] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  225.259286] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  225.265506] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  225.271333] libphy: 1: [drivers/net/phy/phy.c:974] phy_state_machine(): mark
[  225.278644] [drivers/net/ethernet/aurora/nb8800.c: 722] nb8800_link_reconfigure(): mark
[  225.286924] libphy: 1: [drivers/net/phy/phy.c:942] phy_state_machine(): mark: 0, 7
[  225.294777] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  225.302441] nb8800_mdio_read from mdiobus_read
[  225.307139] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  225.313331] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  225.319549] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  225.325387] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  225.333050] nb8800_mdio_read from mdiobus_read
[  225.337751] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  225.343940] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  225.350164] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  225.356003] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  225.363667] nb8800_mdio_read from mdiobus_read
[  225.368364] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  225.374558] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  225.380777] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.386630] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  225.394319] nb8800_mdio_read from mdiobus_read
[  225.399014] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  225.405207] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  225.411428] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  225.417265] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  225.424936] nb8800_mdio_read from mdiobus_read
[  225.429635] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  225.435827] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  225.442049] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.447887] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  225.455549] nb8800_mdio_read from mdiobus_read
[  225.460247] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  225.466438] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  225.472658] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  225.478560] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  225.486232] nb8800_mdio_read from mdiobus_read
[  225.490961] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  225.497153] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  225.503375] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  225.509212] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  225.516874] nb8800_mdio_read from mdiobus_read
[  225.521571] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  225.527763] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  225.533985] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  225.539824] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  225.547538] nb8800_mdio_read from mdiobus_read
[  225.552057] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  225.558332] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  225.564554] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.570393] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  225.578058] nb8800_mdio_read from mdiobus_read
[  225.582756] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  225.588947] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  225.595168] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  225.601020] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  225.608684] nb8800_mdio_read from mdiobus_read
[  225.613400] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  225.619594] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  225.625816] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.631654] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  225.639316] nb8800_mdio_read from mdiobus_read
[  225.644014] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  225.650208] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  225.656430] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  225.662288] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  225.669953] nb8800_mdio_read from mdiobus_read
[  225.674651] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  225.680873] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  225.687089] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  225.692927] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  225.700589] nb8800_mdio_read from mdiobus_read
[  225.705288] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  225.711480] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  225.717738] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  225.723576] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  225.731243] nb8800_mdio_read from mdiobus_read
[  225.735943] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  225.742136] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  225.748356] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.754225] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  225.761888] nb8800_mdio_read from mdiobus_read
[  225.766586] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  225.772778] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  225.778997] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  225.784835] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  225.792499] nb8800_mdio_read from mdiobus_read
[  225.797196] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  225.803390] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  225.809608] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.815447] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  225.823111] nb8800_mdio_read from mdiobus_read
[  225.827808] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  225.834002] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  225.840224] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  225.846086] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  225.853753] nb8800_mdio_read from mdiobus_read
[  225.858451] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  225.864641] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  225.870874] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  225.876534] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  225.884308] nb8800_mdio_read from mdiobus_read
[  225.889005] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  225.895195] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  225.901415] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  225.907253] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  225.914917] nb8800_mdio_read from mdiobus_read
[  225.919613] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  225.925806] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  225.932027] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.937866] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  225.945529] nb8800_mdio_read from mdiobus_read
[  225.950228] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  225.956420] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  225.962639] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  225.968476] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  225.976140] nb8800_mdio_read from mdiobus_read
[  225.980867] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  225.987058] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  225.993277] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  225.999116] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  226.006778] nb8800_mdio_read from mdiobus_read
[  226.011475] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  226.017692] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  226.023913] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  226.029759] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  226.037424] nb8800_mdio_read from mdiobus_read
[  226.042122] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  226.048313] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  226.054535] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  226.060372] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  226.068037] nb8800_mdio_read from mdiobus_read
[  226.072815] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  226.079043] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  226.085301] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  226.091168] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  226.098833] nb8800_mdio_read from mdiobus_read
[  226.103530] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  226.109724] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  226.115945] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  226.121782] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  226.129446] nb8800_mdio_read from mdiobus_read
[  226.134143] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  226.140359] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  226.146574] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  226.152413] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  226.160075] nb8800_mdio_read from mdiobus_read
[  226.164774] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  226.170992] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  226.177210] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  226.183047] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  226.190711] nb8800_mdio_read from mdiobus_read
[  226.195408] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  226.201600] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  226.207822] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  226.213667] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  226.221332] nb8800_mdio_read from mdiobus_read
[  226.226030] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  226.232223] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  226.238444] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  226.244309] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  226.251974] nb8800_mdio_read from mdiobus_read
[  226.256671] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  226.262865] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  226.269087] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  226.274924] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  226.282587] nb8800_mdio_read from mdiobus_read
[  226.287283] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  226.293477] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  226.299716] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  226.305556] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  226.313220] nb8800_mdio_read from mdiobus_read
[  226.317918] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  226.324110] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  226.330329] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  226.336167] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  226.343830] nb8800_mdio_read from mdiobus_read
[  226.348529] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  226.354719] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  226.360970] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  226.366806] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  226.374472] nb8800_mdio_read from mdiobus_read
[  226.379170] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  226.385362] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  226.391584] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  226.397427] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  226.405094] nb8800_mdio_read from mdiobus_read
[  226.409792] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  226.415986] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  226.422212] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  226.428050] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  226.435714] nb8800_mdio_read from mdiobus_read
[  226.440412] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  226.446606] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  226.452829] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  226.458666] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  226.466329] nb8800_mdio_read from mdiobus_read
[  226.471037] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  226.477229] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  226.483450] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  226.489287] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  226.496953] nb8800_mdio_read from mdiobus_read
[  226.501654] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  226.507846] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  226.514068] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  226.519905] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  226.527618] nb8800_mdio_read from mdiobus_read
[  226.532318] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  226.538513] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  226.544733] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  226.550573] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  226.558236] nb8800_mdio_read from mdiobus_read
[  226.562932] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  226.569126] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  226.575347] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  226.581208] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  226.588872] nb8800_mdio_read from mdiobus_read
[  226.593568] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  226.599760] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  226.605982] ++ETH r32 [f0026024] 00007949 from mdiobus_read
[  226.611817] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  226.619479] nb8800_mdio_read from mdiobus_read
[  226.624205] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  226.630394] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  226.636616] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  226.642453] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  226.650117] nb8800_mdio_read from mdiobus_read
[  226.654814] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  226.661041] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  226.667262] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  226.673102] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  226.680765] nb8800_mdio_read from mdiobus_read
[  226.685464] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  226.691657] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  226.697878] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  226.703713] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  226.711379] nb8800_mdio_read from mdiobus_read
[  226.716075] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  226.722268] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  226.728489] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  226.734349] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  226.742014] nb8800_mdio_read from mdiobus_read
[  226.746710] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  226.752921] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  226.759144] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  226.764983] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_aneg_done
[  226.772473] nb8800_mdio_read from mdiobus_read
[  226.777170] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  226.783363] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  226.789583] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  226.795415] libphy: 1: [drivers/net/phy/phy.c:1016] phy_state_machine(): mark
[  226.802815] [drivers/net/ethernet/aurora/nb8800.c: 722] nb8800_link_reconfigure(): mark
[  226.811105] ++ETH w8 [f0026050] 01 from phy_state_machine
[  226.816766] ++ETH w8 [f002601c] 80 from phy_state_machine
[  226.822424] ++ETH r8 [f0026044] 00 from phy_state_machine
[  226.828082] ++ETH r8 [f0026004] 23 from nb8800_link_reconfigure
[  226.834293] ++ETH w8 [f0026004] 2b from nb8800_link_reconfigure
[  226.840474] ++ETH r32 [f0026200] 06100a8f from nb8800_link_reconfigure
[  226.847315] ++ETH r8 [f0026004] 2b from nb8800_dma_stop
[  226.852625] ++ETH w8 [f0026004] 0b from nb8800_dma_stop
[  226.857919] ++ETH r8 [f0026044] 00 from nb8800_pause_config
[  226.863559] ++ETH w8 [f0026044] 04 from nb8800_pause_config
[  226.869200] ++ETH w32 [f002610c] 8fbf4000 from nb8800_pause_config
[  226.875452] ++ETH w32 [f0026100] 000002ff from nb8800_pause_config
[  226.881709] [drivers/net/ethernet/aurora/nb8800.c: 587] nb8800_irq(): mark
[  226.888640] ++ETH r32 [f0026104] 00000004 from handle_irq_event_percpu
[  226.895210] [drivers/net/ethernet/aurora/nb8800.c: 592] nb8800_irq(): tx irq, 0x00000004
[  226.903357] ++ETH w32 [f0026104] 00000004 from handle_irq_event_percpu
[  226.909931] ++ETH r32 [f0026204] 00000004 from handle_irq_event_percpu
[  226.916501] [drivers/net/ethernet/aurora/nb8800.c: 621] nb8800_irq(): rx irq, 0x00000004
[  226.924646] ++ETH w32 [f0026204] 00000004 from handle_irq_event_percpu
[  226.931219] ++ETH w32 [f0026218] 003cc4a4 from handle_irq_event_percpu
[  226.937819] [drivers/net/ethernet/aurora/nb8800.c: 587] nb8800_irq(): mark
[  226.944746] ++ETH r32 [f0026104] 00000001 from handle_irq_event_percpu
[  226.951318] [drivers/net/ethernet/aurora/nb8800.c: 592] nb8800_irq(): tx irq, 0x00000001
[  226.959462] ++ETH w32 [f0026104] 00000001 from handle_irq_event_percpu
[  226.966035] ++ETH r32 [f0026204] 00000000 from handle_irq_event_percpu
[  226.982648] ++ETH w32 [f002610c] 8fbf4000 from nb8800_pause_config
[  226.988901] ++ETH w32 [f0026100] 000002ff from nb8800_pause_config
[  226.995154] [drivers/net/ethernet/aurora/nb8800.c: 587] nb8800_irq(): mark
[  227.002080] ++ETH r32 [f0026104] 00000004 from handle_irq_event_percpu
[  227.008650] [drivers/net/ethernet/aurora/nb8800.c: 592] nb8800_irq(): tx irq, 0x00000004
[  227.016796] ++ETH w32 [f0026104] 00000004 from handle_irq_event_percpu
[  227.023369] ++ETH r32 [f0026204] 00000004 from handle_irq_event_percpu
[  227.029938] [drivers/net/ethernet/aurora/nb8800.c: 621] nb8800_irq(): rx irq, 0x00000004
[  227.038083] ++ETH w32 [f0026204] 00000004 from handle_irq_event_percpu
[  227.044656] ++ETH w32 [f0026218] 003cc4a4 from handle_irq_event_percpu
[  227.051253] [drivers/net/ethernet/aurora/nb8800.c: 587] nb8800_irq(): mark
[  227.058178] ++ETH r32 [f0026104] 00000001 from handle_irq_event_percpu
[  227.064747] [drivers/net/ethernet/aurora/nb8800.c: 592] nb8800_irq(): tx irq, 0x00000001
[  227.072892] ++ETH w32 [f0026104] 00000001 from handle_irq_event_percpu
[  227.079465] ++ETH r32 [f0026204] 00000000 from handle_irq_event_percpu
[  227.096078] ++ETH w32 [f002610c] 8fbf4000 from nb8800_pause_config
[  227.102331] ++ETH w32 [f0026100] 000002ff from nb8800_pause_config
[  227.108584] [drivers/net/ethernet/aurora/nb8800.c: 587] nb8800_irq(): mark
[  227.115510] ++ETH r32 [f0026104] 00000004 from handle_irq_event_percpu
[  227.122080] [drivers/net/ethernet/aurora/nb8800.c: 592] nb8800_irq(): tx irq, 0x00000004
[  227.130225] ++ETH w32 [f0026104] 00000004 from handle_irq_event_percpu
[  227.136799] ++ETH r32 [f0026204] 00000004 from handle_irq_event_percpu
[  227.143367] [drivers/net/ethernet/aurora/nb8800.c: 621] nb8800_irq(): rx irq, 0x00000004
[  227.151512] ++ETH w32 [f0026204] 00000004 from handle_irq_event_percpu
[  227.158085] ++ETH w32 [f0026218] 003cc4a4 from handle_irq_event_percpu
[  227.164683] [drivers/net/ethernet/aurora/nb8800.c: 587] nb8800_irq(): mark
[  227.171608] ++ETH r32 [f0026104] 00000001 from handle_irq_event_percpu
[  227.178179] [drivers/net/ethernet/aurora/nb8800.c: 592] nb8800_irq(): tx irq, 0x00000001
[  227.186324] ++ETH w32 [f0026104] 00000001 from handle_irq_event_percpu
[  227.192897] ++ETH r32 [f0026204] 00000000 from handle_irq_event_percpu
[  227.199500] ++ETH r8 [f0026004] 0b from nb8800_dma_stop
[  227.204788] ++ETH w8 [f0026004] 2b from nb8800_dma_stop
[  227.210077] ++ETH r8 [f0026044] 04 from nb8800_pause_config
[  227.215714] ++ETH w8 [f0026044] 00 from nb8800_pause_config
[  227.221378] ++ETH w32 [f002620c] 8fbfa000 from nb8800_dma_stop
[  227.227282] ++ETH r32 [f0026200] 06100a8e from nb8800_link_reconfigure
[  227.233882] ++ETH w32 [f0026200] 06102a8e from nb8800_link_reconfigure
[  227.240482] ++ETH r32 [f0026200] 06102a8e from nb8800_pause_config
[  227.246731] ++ETH w32 [f0026200] 06102a8f from nb8800_pause_config
[  227.258188] nb8800 26000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
[  227.266299] libphy: 1: [drivers/net/phy/phy.c:942] phy_state_machine(): mark: 0, 6
[  227.274289] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  227.281958] nb8800_mdio_read from mdiobus_read
[  227.286658] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  227.292853] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  227.299074] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  227.304913] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  227.312577] nb8800_mdio_read from mdiobus_read
[  227.317275] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  227.323470] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  227.329692] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  227.335530] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  227.343197] nb8800_mdio_read from mdiobus_read
[  227.347896] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  227.354087] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  227.360308] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  227.366147] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  227.373811] nb8800_mdio_read from mdiobus_read
[  227.378508] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  227.384701] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  227.390953] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  227.396790] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  227.404455] nb8800_mdio_read from mdiobus_read
[  227.409151] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  227.415345] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  227.421572] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  227.427411] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  227.435076] nb8800_mdio_read from mdiobus_read
[  227.439776] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  227.445968] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  227.452192] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  227.458144] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  227.465840] nb8800_mdio_read from mdiobus_read
[  227.470543] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  227.476735] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  227.482956] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  227.488796] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  227.496462] nb8800_mdio_read from mdiobus_read
[  227.501160] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  227.507354] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  227.513579] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  227.519417] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  227.527082] nb8800_mdio_read from mdiobus_read
[  227.531779] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  227.537971] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  227.544209] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  227.549869] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  227.557646] nb8800_mdio_read from mdiobus_read
[  227.562344] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  227.568536] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  227.574757] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  227.580596] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  227.588260] nb8800_mdio_read from mdiobus_read
[  227.592956] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  227.599150] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  227.605370] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  227.611208] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  227.618872] nb8800_mdio_read from mdiobus_read
[  227.623570] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  227.629765] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  227.635987] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  227.641835] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  227.649499] nb8800_mdio_read from mdiobus_read
[  227.654226] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  227.660417] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  227.666639] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  227.672475] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  227.680139] nb8800_mdio_read from mdiobus_read
[  227.684837] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  227.691057] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  227.697280] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  227.703119] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  227.710785] nb8800_mdio_read from mdiobus_read
[  227.715484] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  227.721678] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  227.727899] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  227.733736] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  227.741401] nb8800_mdio_read from mdiobus_read
[  227.746098] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  227.752292] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  227.758513] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  227.764364] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  227.772027] nb8800_mdio_read from mdiobus_read
[  227.776722] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  227.782914] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  227.789135] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  227.794972] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  227.802634] nb8800_mdio_read from mdiobus_read
[  227.807333] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  227.813526] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  227.819746] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  227.825592] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  227.833257] nb8800_mdio_read from mdiobus_read
[  227.837956] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  227.844148] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  227.850394] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  227.856228] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  227.863892] nb8800_mdio_read from mdiobus_read
[  227.868591] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  227.874784] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  227.881028] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  227.886867] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  227.894531] nb8800_mdio_read from mdiobus_read
[  227.899230] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  227.905423] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  227.911641] ++ETH r32 [f0026024] 00000001 from mdiobus_read
[  227.917478] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  227.925197] nb8800_mdio_read from mdiobus_read
[  227.929892] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  227.936086] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  227.942310] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  227.948148] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  227.955813] nb8800_mdio_read from mdiobus_read
[  227.960511] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  227.966704] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  227.972927] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  227.978766] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  227.986430] nb8800_mdio_read from mdiobus_read
[  227.991129] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  227.997322] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  228.003545] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  228.009391] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.017056] nb8800_mdio_read from mdiobus_read
[  228.021754] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  228.027948] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  228.034210] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  228.039868] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.047647] nb8800_mdio_read from mdiobus_read
[  228.052345] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  228.058540] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  228.064762] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  228.070599] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  228.078331] nb8800_mdio_read from mdiobus_read
[  228.083064] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  228.089300] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  228.095552] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  228.101393] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  228.109058] nb8800_mdio_read from mdiobus_read
[  228.113757] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  228.119950] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  228.126172] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  228.132011] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  228.139675] nb8800_mdio_read from mdiobus_read
[  228.144373] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  228.150583] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  228.156806] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  228.162644] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  228.170308] nb8800_mdio_read from mdiobus_read
[  228.175006] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  228.181200] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  228.187422] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  228.193276] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.200972] nb8800_mdio_read from mdiobus_read
[  228.205670] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  228.211862] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  228.218083] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  228.223920] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.231585] nb8800_mdio_read from mdiobus_read
[  228.236282] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  228.242474] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  228.248695] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  228.254534] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  228.262197] nb8800_mdio_read from mdiobus_read
[  228.266895] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  228.273086] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  228.279308] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  228.285144] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  228.292809] nb8800_mdio_read from mdiobus_read
[  228.297535] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  228.303726] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  228.309950] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  228.315788] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  228.323452] nb8800_mdio_read from mdiobus_read
[  228.328149] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  228.334354] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  228.340575] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  228.346415] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  228.354081] nb8800_mdio_read from mdiobus_read
[  228.358781] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  228.364974] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  228.371194] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  228.377057] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.384725] nb8800_mdio_read from mdiobus_read
[  228.389422] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  228.395615] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  228.401837] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  228.407686] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.415352] nb8800_mdio_read from mdiobus_read
[  228.420052] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  228.426246] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  228.432469] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  228.438306] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  228.445970] nb8800_mdio_read from mdiobus_read
[  228.450669] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  228.456860] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  228.463083] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  228.468921] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  228.476585] nb8800_mdio_read from mdiobus_read
[  228.481284] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  228.487476] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  228.493720] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  228.499554] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  228.507219] nb8800_mdio_read from mdiobus_read
[  228.511918] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  228.518111] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  228.524359] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  228.530197] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  228.537863] nb8800_mdio_read from mdiobus_read
[  228.542561] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  228.548754] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  228.554977] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  228.560893] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.568378] nb8800_mdio_read from mdiobus_read
[  228.573157] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  228.579353] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  228.585575] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  228.591413] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.599078] nb8800_mdio_read from mdiobus_read
[  228.603792] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  228.609985] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  228.616208] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  228.622047] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  228.629708] nb8800_mdio_read from mdiobus_read
[  228.634408] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  228.640601] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  228.646822] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  228.652661] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  228.660323] nb8800_mdio_read from mdiobus_read
[  228.665021] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  228.671216] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  228.677436] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  228.683274] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  228.690967] nb8800_mdio_read from mdiobus_read
[  228.695663] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  228.701857] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  228.708081] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  228.713918] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  228.721583] nb8800_mdio_read from mdiobus_read
[  228.726280] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  228.732471] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  228.738693] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  228.744539] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.752204] nb8800_mdio_read from mdiobus_read
[  228.756901] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  228.763094] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  228.769316] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  228.775153] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.782817] nb8800_mdio_read from mdiobus_read
[  228.787545] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  228.793735] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  228.799955] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  228.805792] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  228.813455] nb8800_mdio_read from mdiobus_read
[  228.818153] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  228.824358] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  228.830594] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  228.836434] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  228.844097] nb8800_mdio_read from mdiobus_read
[  228.848797] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  228.854989] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  228.861209] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  228.867047] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  228.874712] nb8800_mdio_read from mdiobus_read
[  228.879411] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  228.885603] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  228.891826] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  228.897682] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  228.905347] nb8800_mdio_read from mdiobus_read
[  228.910045] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  228.916049] [drivers/net/ethernet/aurora/nb8800.c: 587] nb8800_irq(): mark
[  228.916067] ++ETH r32 [f0026104] 00000000 from handle_irq_event_percpu
[  228.916081] ++ETH r32 [f0026204] 00000004 from handle_irq_event_percpu
[  228.916090] [drivers/net/ethernet/aurora/nb8800.c: 621] nb8800_irq(): rx irq, 0x00000004
[  228.916103] ++ETH w32 [f0026204] 00000004 from handle_irq_event_percpu
[  228.916115] ++ETH w32 [f0026218] 003cc4a4 from handle_irq_event_percpu
[  228.916514] [drivers/net/ethernet/aurora/nb8800.c: 326] nb8800_poll(): mark
[  228.916540] ++ETH w32 [f0026218] 00004dc8 from net_rx_action
[  228.971056] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  228.977448] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  228.983299] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  228.990990] nb8800_mdio_read from mdiobus_read
[  228.995688] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.001884] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.008106] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.013942] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.021608] nb8800_mdio_read from mdiobus_read
[  229.026305] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.032497] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.038719] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.044556] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  229.052221] nb8800_mdio_read from mdiobus_read
[  229.056918] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  229.063126] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  229.069349] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  229.075253] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  229.082952] nb8800_mdio_read from mdiobus_read
[  229.087721] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  229.093943] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  229.100165] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  229.106004] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  229.113669] nb8800_mdio_read from mdiobus_read
[  229.118369] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  229.124563] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  229.130784] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  229.136622] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  229.144314] nb8800_mdio_read from mdiobus_read
[  229.149011] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  229.155204] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  229.161426] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  229.167270] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.174936] nb8800_mdio_read from mdiobus_read
[  229.179634] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.185828] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.192050] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.197888] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.205554] nb8800_mdio_read from mdiobus_read
[  229.210250] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.216443] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.222666] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.228503] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  229.236166] nb8800_mdio_read from mdiobus_read
[  229.240894] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  229.247084] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  229.253305] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  229.259141] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  229.266804] nb8800_mdio_read from mdiobus_read
[  229.271504] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  229.277709] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  229.283932] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  229.289788] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  229.297455] nb8800_mdio_read from mdiobus_read
[  229.302154] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  229.308347] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  229.314567] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  229.320407] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  229.328072] nb8800_mdio_read from mdiobus_read
[  229.332767] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  229.338961] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  229.345181] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  229.351040] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.358706] nb8800_mdio_read from mdiobus_read
[  229.363406] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.369600] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.375820] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.381658] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.389323] nb8800_mdio_read from mdiobus_read
[  229.394021] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.400214] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.406436] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.412273] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  229.419940] nb8800_mdio_read from mdiobus_read
[  229.424643] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  229.430866] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  229.437084] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  229.442922] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  229.450585] nb8800_mdio_read from mdiobus_read
[  229.455284] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  229.461476] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  229.467735] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  229.473571] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  229.481236] nb8800_mdio_read from mdiobus_read
[  229.485933] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  229.492127] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  229.498349] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  229.504217] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  229.511879] nb8800_mdio_read from mdiobus_read
[  229.516595] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  229.522789] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  229.529010] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  229.534951] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.542624] nb8800_mdio_read from mdiobus_read
[  229.547324] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.553517] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.559740] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.565579] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.573244] nb8800_mdio_read from mdiobus_read
[  229.577942] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.584132] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.590354] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.596192] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  229.603856] nb8800_mdio_read from mdiobus_read
[  229.608556] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  229.614750] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  229.621000] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  229.626836] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  229.634501] nb8800_mdio_read from mdiobus_read
[  229.639198] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  229.645391] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  229.651613] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  229.657449] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  229.665115] nb8800_mdio_read from mdiobus_read
[  229.669812] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  229.676006] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  229.682226] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  229.688064] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  229.695729] nb8800_mdio_read from mdiobus_read
[  229.700427] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  229.706620] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  229.712842] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  229.718691] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.726356] nb8800_mdio_read from mdiobus_read
[  229.731056] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.737250] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.743488] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.749324] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.756991] nb8800_mdio_read from mdiobus_read
[  229.761689] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.767884] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.774105] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.779942] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  229.787633] nb8800_mdio_read from mdiobus_read
[  229.792330] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  229.798522] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  229.804741] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  229.810580] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  229.818247] nb8800_mdio_read from mdiobus_read
[  229.822946] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  229.829138] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  229.835360] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  229.841196] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  229.848860] nb8800_mdio_read from mdiobus_read
[  229.853555] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  229.859748] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  229.865969] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  229.871806] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  229.879469] nb8800_mdio_read from mdiobus_read
[  229.884192] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  229.890379] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  229.896603] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  229.902448] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.910116] nb8800_mdio_read from mdiobus_read
[  229.914813] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.921039] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.927260] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.933098] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  229.940765] nb8800_mdio_read from mdiobus_read
[  229.945461] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  229.951656] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  229.957878] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  229.963716] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  229.971399] nb8800_mdio_read from mdiobus_read
[  229.976099] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  229.982292] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  229.988514] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  229.994363] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  230.002028] nb8800_mdio_read from mdiobus_read
[  230.006726] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  230.012918] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  230.019140] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  230.024977] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  230.032642] nb8800_mdio_read from mdiobus_read
[  230.037341] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  230.043536] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  230.049759] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  230.055596] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  230.063260] nb8800_mdio_read from mdiobus_read
[  230.067958] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  230.074274] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  230.080529] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  230.086405] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  230.094072] nb8800_mdio_read from mdiobus_read
[  230.098772] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  230.104965] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  230.111186] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  230.117024] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  230.124690] nb8800_mdio_read from mdiobus_read
[  230.129385] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  230.135579] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  230.141801] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  230.147663] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  230.155327] nb8800_mdio_read from mdiobus_read
[  230.160024] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  230.166218] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  230.172440] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  230.178277] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  230.185942] nb8800_mdio_read from mdiobus_read
[  230.190639] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  230.196832] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  230.203073] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  230.208914] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  230.216580] nb8800_mdio_read from mdiobus_read
[  230.221279] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  230.227472] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  230.233719] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  230.239551] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  230.247215] nb8800_mdio_read from mdiobus_read
[  230.251913] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  230.258106] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  230.264353] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  230.270199] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  230.277863] nb8800_mdio_read from mdiobus_read
[  230.282560] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  230.288752] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  230.294974] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  230.300813] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  230.308505] nb8800_mdio_read from mdiobus_read
[  230.313197] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  230.319390] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  230.325612] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  230.331448] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  230.339113] nb8800_mdio_read from mdiobus_read
[  230.343811] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  230.350003] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  230.356226] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  230.362066] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  230.369729] nb8800_mdio_read from mdiobus_read
[  230.374426] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  230.380619] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  230.386839] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  230.392675] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  230.400339] nb8800_mdio_read from mdiobus_read
[  230.405036] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  230.411229] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  230.417449] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  230.423293] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  230.431000] nb8800_mdio_read from mdiobus_read
[  230.435699] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  230.441894] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  230.448116] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  230.453977] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  230.461643] nb8800_mdio_read from mdiobus_read
[  230.466341] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  230.472536] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  230.478757] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  230.484594] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  230.492258] nb8800_mdio_read from mdiobus_read
[  230.496956] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  230.503150] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  230.509370] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  230.515207] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  230.522873] nb8800_mdio_read from mdiobus_read
[  230.527600] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  230.533793] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  230.540013] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  230.545851] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  230.553516] nb8800_mdio_read from mdiobus_read
[  230.558215] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  230.564410] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  230.570629] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  230.576467] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  230.584132] nb8800_mdio_read from mdiobus_read
[  230.588831] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  230.595024] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  230.601245] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  230.607084] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  230.614750] nb8800_mdio_read from mdiobus_read
[  230.619448] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  230.625642] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  230.631865] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  230.637710] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  230.645377] nb8800_mdio_read from mdiobus_read
[  230.650076] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  230.656288] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  230.662511] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  230.668350] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  230.676015] nb8800_mdio_read from mdiobus_read
[  230.680713] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  230.686907] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  230.693131] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  230.698968] libphy: mdiobus_read: addr=4 regnum=0000000a from genphy_read_status
[  230.706633] nb8800_mdio_read from mdiobus_read
[  230.711333] ++ETH w32 [f0026020] 008a0000 from nb8800_mdio_read
[  230.717555] ++ETH w32 [f0026020] 808a0000 from nb8800_mdio_read
[  230.723773] ++ETH r32 [f0026024] 00000000 from mdiobus_read
[  230.729612] libphy: mdiobus_read: addr=4 regnum=00000009 from genphy_read_status
[  230.737278] nb8800_mdio_read from mdiobus_read
[  230.741976] ++ETH w32 [f0026020] 00890000 from nb8800_mdio_read
[  230.748168] ++ETH w32 [f0026020] 80890000 from nb8800_mdio_read
[  230.754402] ++ETH r32 [f0026024] 00000200 from mdiobus_read
[  230.760240] libphy: mdiobus_read: addr=4 regnum=00000005 from genphy_read_status
[  230.767905] nb8800_mdio_read from mdiobus_read
[  230.772603] ++ETH w32 [f0026020] 00850000 from nb8800_mdio_read
[  230.778799] ++ETH w32 [f0026020] 80850000 from nb8800_mdio_read
[  230.785019] ++ETH r32 [f0026024] 000045e1 from mdiobus_read
[  230.790885] libphy: mdiobus_read: addr=4 regnum=00000004 from genphy_read_status
[  230.798548] nb8800_mdio_read from mdiobus_read
[  230.803245] ++ETH w32 [f0026020] 00840000 from nb8800_mdio_read
[  230.809438] ++ETH w32 [f0026020] 80840000 from nb8800_mdio_read
[  230.815661] ++ETH r32 [f0026024] 000015e1 from mdiobus_read
[  230.821508] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  230.829173] nb8800_mdio_read from mdiobus_read
[  230.833871] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  230.840066] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  230.846287] ++ETH r32 [f0026024] 0000796d from mdiobus_read
[  230.852127] libphy: mdiobus_read: addr=4 regnum=00000001 from genphy_update_link
[  230.859793] nb8800_mdio_read from mdiobus_read
[  230.864491] ++ETH w32 [f0026020] 00810000 from nb8800_mdio_read
[  230.870682] ++ETH w32 [f0026020] 80810000 from nb8800_mdio_read
[  230.876904] ++ETH r32 [f0026024] 0000796d from mdiobus_read
snip more lines

The regnum=5,4,1,1,a,9 logs keep repeating, endlessly.
Is that expected?

If anyone spots something fishy, I'd be extremely grateful for any leads.

Regards.
