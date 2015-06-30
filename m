From: Sebastian Ott <sebott@linux.vnet.ibm.com>
Subject: mlx4: "failed to allocate default counter port 1"
Date: Tue, 30 Jun 2015 12:45:12 +0200 (CEST)
Message-ID: <alpine.LFD.2.11.1506301229520.1799@denkbrett>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

after the latest mellanox update the mlx4 driver fails to probe a VF:
[   88.909562] mlx4_core 0000:00:00.0: mlx4_allocate_default_counters: failed to allocate default counter port 1 err -22
[   88.909564] mlx4_core 0000:00:00.0: Failed to allocate default counters, aborting
[   88.961735] mlx4_core: probe of 0000:00:00.0 failed with error -22

PFs still work. See below for more dmesg output - I also added a line of
debug output...maybe this helps.

Regards,
Sebastian

# git diff
diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c 
b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 8204013..e0c41c3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -565,6 +565,9 @@ static int mlx4_slave_cmd(struct mlx4_dev *dev, u64 in_param, u64 *out_param,
                                }
                        }
                        ret = mlx4_status_to_errno(vhcr->status);
+                       if (ret)
+                               printk(KERN_WARNING"%s op=%d, ret=%d, status=%d\n",
+                                      __func__, op, ret, vhcr->status);
                } else {
                        if (dev->persist->state &
                            MLX4_DEVICE_STATE_INTERNAL_ERROR)
# git describe
v4.1-11355-g6aaf0da
# dmesg
[   88.518946] mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
[   88.518967] mlx4_core: Initializing 0000:00:00.0
[   88.519101] mlx4_core 0000:00:00.0: enabling device (0000 -> 0002)
[   88.519661] mlx4_core 0000:00:00.0: enabling bus mastering
[   88.520279] mlx4_core 0000:00:00.0: Detected virtual function - running in slave mode
[   88.520404] mlx4_core 0000:00:00.0: Sending reset
[   88.526726] mlx4_core 0000:00:00.0: Sending vhcr0
[   88.539676] mlx4_core 0000:00:00.0: BlueFlame not available
[   88.539678] mlx4_core 0000:00:00.0: Base MM extensions: flags 31104ec2, rsvd L_Key 00008000
[   88.539680] mlx4_core 0000:00:00.0: Max ICM size 4294967296 MB
[   88.539682] mlx4_core 0000:00:00.0: Max QPs: 16777216, reserved QPs: 64, entry size: 256
[   88.539683] mlx4_core 0000:00:00.0: Max SRQs: 16777216, reserved SRQs: 64, entry size: 128
[   88.539685] mlx4_core 0000:00:00.0: Max CQs: 16777216, reserved CQs: 128, entry size: 128
[   88.539687] mlx4_core 0000:00:00.0: Num sys EQs: 1024, max EQs: 512, reserved EQs: 8, entry size: 128
[   88.539688] mlx4_core 0000:00:00.0: reserved MPTs: 256, reserved MTTs: 64
[   88.539690] mlx4_core 0000:00:00.0: Max PDs: 131072, reserved PDs: 4, reserved UARs: 2
[   88.539691] mlx4_core 0000:00:00.0: Max QP/MCG: 131072, reserved MGMs: 0
[   88.539693] mlx4_core 0000:00:00.0: Max CQEs: 4194304, max WQEs: 16384, max SRQ WQEs: 16384
[   88.539695] mlx4_core 0000:00:00.0: Local CA ACK delay: 15, max MTU: 4096, port width cap: 3
[   88.539696] mlx4_core 0000:00:00.0: Max SQ desc size: 1008, max SQ S/G: 62
[   88.539698] mlx4_core 0000:00:00.0: Max RQ desc size: 512, max RQ S/G: 32
[   88.539699] mlx4_core 0000:00:00.0: Max GSO size: 131072
[   88.539701] mlx4_core 0000:00:00.0: Max counters: 256
[   88.539702] mlx4_core 0000:00:00.0: Max RSS Table size: 256
[   88.539704] mlx4_core 0000:00:00.0: DMFS high rate steer QPn base: 64
[   88.539705] mlx4_core 0000:00:00.0: DMFS high rate steer QPn range: 254
[   88.539707] mlx4_core 0000:00:00.0: QP Rate-Limit: #rates 1024, unit/val max 3/40, min 1/512
[   88.539709] mlx4_core 0000:00:00.0: DEV_CAP flags:
[   88.539710] mlx4_core 0000:00:00.0:     RC transport
[   88.539711] mlx4_core 0000:00:00.0:     UC transport
[   88.539713] mlx4_core 0000:00:00.0:     UD transport
[   88.539714] mlx4_core 0000:00:00.0:     XRC transport
[   88.539716] mlx4_core 0000:00:00.0:     SRQ support
[   88.539717] mlx4_core 0000:00:00.0:     IPoIB checksum offload
[   88.539719] mlx4_core 0000:00:00.0:     P_Key violation counter
[   88.539720] mlx4_core 0000:00:00.0:     Q_Key violation counter
[   88.539722] mlx4_core 0000:00:00.0:     Big LSO headers
[   88.539723] mlx4_core 0000:00:00.0:     MW support
[   88.539724] mlx4_core 0000:00:00.0:     APM support
[   88.539726] mlx4_core 0000:00:00.0:     Atomic ops support
[   88.539727] mlx4_core 0000:00:00.0:     Address vector port checking support
[   88.539729] mlx4_core 0000:00:00.0:     UD multicast support
[   88.539730] mlx4_core 0000:00:00.0:     IBoE support
[   88.539732] mlx4_core 0000:00:00.0:     Unicast loopback support
[   88.539733] mlx4_core 0000:00:00.0:     FCS header control
[   88.539735] mlx4_core 0000:00:00.0:     UDP RSS support
[   88.539736] mlx4_core 0000:00:00.0:     Unicast VEP steering support
[   88.539738] mlx4_core 0000:00:00.0:     Multicast VEP steering support
[   88.539739] mlx4_core 0000:00:00.0:     Counters support
[   88.539741] mlx4_core 0000:00:00.0:     RSS IP fragments support
[   88.539742] mlx4_core 0000:00:00.0:     Port ETS Scheduler support
[   88.539744] mlx4_core 0000:00:00.0:     Port link type sensing support
[   88.539745] mlx4_core 0000:00:00.0:     Port management change event support
[   88.539747] mlx4_core 0000:00:00.0:     64 byte EQE support
[   88.539748] mlx4_core 0000:00:00.0:     64 byte CQE support
[   88.539749] mlx4_core 0000:00:00.0:     RSS support
[   88.539751] mlx4_core 0000:00:00.0:     RSS Toeplitz Hash Function support
[   88.539752] mlx4_core 0000:00:00.0:     RSS XOR Hash Function support
[   88.539754] mlx4_core 0000:00:00.0:     Device managed flow steering support
[   88.539755] mlx4_core 0000:00:00.0:     Automatic MAC reassignment support
[   88.539757] mlx4_core 0000:00:00.0:     Time stamping support
[   88.539758] mlx4_core 0000:00:00.0:     VST (control vlan insertion/stripping) support
[   88.539760] mlx4_core 0000:00:00.0:     FSM (MAC anti-spoofing) support
[   88.539761] mlx4_core 0000:00:00.0:     Dynamic QP updates support
[   88.539763] mlx4_core 0000:00:00.0:     MAD DEMUX (Secure-Host) support
[   88.539764] mlx4_core 0000:00:00.0:     Large cache line (>64B) CQE stride support
[   88.539766] mlx4_core 0000:00:00.0:     Large cache line (>64B) EQE stride support
[   88.539767] mlx4_core 0000:00:00.0:     Ethernet protocol control support
[   88.539769] mlx4_core 0000:00:00.0:     Ethernet Backplane autoneg support
[   88.539770] mlx4_core 0000:00:00.0:     CONFIG DEV support
[   88.539771] mlx4_core 0000:00:00.0:     Asymmetric EQs support
[   88.539773] mlx4_core 0000:00:00.0:     More than 80 VFs support
[   88.539774] mlx4_core 0000:00:00.0:     Recoverable error events support
[   88.539776] mlx4_core 0000:00:00.0:     Port Remap support
[   88.539777] mlx4_core 0000:00:00.0:     QCN support
[   88.539779] mlx4_core 0000:00:00.0:     QP rate limiting support
[   88.539780] mlx4_core 0000:00:00.0:     Ethernet Flow control statistics support
[   88.539782] mlx4_core 0000:00:00.0:     Granular QoS per VF support
[   88.539783] mlx4_core 0000:00:00.0:     Port beacon support
[   88.540492] mlx4_core 0000:00:00.0: HCA minimum page size:512
[   88.543436] mlx4_core 0000:00:00.0: Timestamping is not supported in slave mode
[   88.543438] mlx4_core 0000:00:00.0: Steering mode is: Device managed flow steering
[   88.543440] mlx4_core 0000:00:00.0: RSS support for IP fragments is off
[   88.543441] mlx4_core 0000:00:00.0: Failed to map blue flame area
[   88.909056] mlx4_core 0000:00:00.0: NOP command IRQ test passed
[   88.909558] mlx4_slave_cmd op=3840, ret=-22, status=3
[   88.909562] mlx4_core 0000:00:00.0: mlx4_allocate_default_counters: failed to allocate default counter port 1 err -22
[   88.909564] mlx4_core 0000:00:00.0: Failed to allocate default counters, aborting
[   88.961735] mlx4_core: probe of 0000:00:00.0 failed with error -22
