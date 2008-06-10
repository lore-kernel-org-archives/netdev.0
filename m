From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Subject: [ofa-general] [PATCH v4 14/14] QLogic VNIC: sysfs Documentation
Date: Tue, 10 Jun 2008 17:09:18 -0400
Message-ID: <20080610210918.11186.64253.stgit@dale>
References: <20080610205633.11186.45499.stgit@dale>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: amar.mudrankit@qlogic.com, poornima.kamath@qlogic.com
To: rdreier@cisco.com, general@lists.openfabrics.org, netdev@vger.kernel.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080610205633.11186.45499.stgit@dale>
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

From: Amar Mudrankit <amar.mudrankit@qlogic.com>

This patch adds the file sysfs-class-infiniband-qlgc-vnic which
describes the sysfs files managed by QLogic VNIC.

Signed-off-by: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>
---

 .../ABI/testing/sysfs-class-infiniband-qlgc-vnic   |  179 ++++++++++++++++++++
 1 files changed, 179 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-class-infiniband-qlgc-vnic

diff --git a/Documentation/ABI/testing/sysfs-class-infiniband-qlgc-vnic b/Documentation/ABI/testing/sysfs-class-infiniband-qlgc-vnic
new file mode 100644
index 0000000..6cf22ac
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-infiniband-qlgc-vnic
@@ -0,0 +1,179 @@
+What:		/sys/class/infiniband_qlgc_vnic/
+Date:		June 2008
+KernelVersion:	2.6.27
+Contact:	Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
+Description:
+
+sysfs interface:
+----------------
+
+The QLogic Virtual NIC module when loaded on host creates following set of
+files into the sysfs:
+
+/sys/class/infiniband_qlgc_vnic/interfaces
+
+	create_vnic	(0200)	To create a new VNIC interface, write the name
+				of the interface to this file.
+
+	delete_vnic	(0200)	To delete an existing VNIC interface, write
+				name of that VNIC interface to this file.
+
+/sys/class/infiniband_qlgc_vnic/interfaces/<VNIC-interface-name>/
+
+	vnic_state	(0444)	State of the VNIC interface.
+
+	current_path	(0444)	In case of failover configuration, which
+				connection among the primary and secondary is
+				currently being used.
+
+	multicast	(0644)	Get/Set IB multicast value for the VNIC
+				interface.  Only root can Enable/Disable IB
+				multicast for that VNIC interface.
+
+	rx_csum		(0644)	Get/Set receive checksum boolean value for VNIC
+				interface.  Only root can Enable/Disable the
+				receive checksum operation for that VNIC
+				interface.
+
+	tx_csum		(0644)	Get/Set transmit checksum boolean value for VNIC
+				interface.  Only root can Enable/Disable the
+				transmit checksum operation for that VNIC
+				interface.
+
+/sys/class/infiniband_qlgc_vnic/interfaces/<VNIC-interface-name>/[primary-secondary]_path
+
+	dgid		(0644)	Get/set destination GID value for this
+				connection of VNIC interface.
+
+	hca_info	(0444)	Get the information about the HCA and IB port
+				through which this connection has been
+				configured.
+
+	heartbeat	(0644)	Get/Set the heartbeat value for this connection
+				of VNIC interface.
+
+	instance	(0644)	Get/Set instance number associated with this
+				connection of VNIC interface.
+
+	ioc_guid	(0644)	Set/Get GUID value of I/O Controller to which
+				this connection of VNIC interface should be/is
+				connecting to.
+
+	ioc_string	(0644)	Set/Get string value of I/O Controller to which
+				this connection of VNIC interface should be/is
+				connecting to.
+
+	link_state	(0444)	Link state for this connection.
+
+	multicast_state	(0444)	IB multicast state for this connection.
+
+	pkey		(0644)	Get/Set pkey value for this connection of VNIC
+				interface.
+
+	viport_state	(0444)	Viport state of this connection.
+
+/sys/class/infiniband_qlgc_vnic/vnic-<HCA-name>-<IB-port-no>
+
+	create_primary	(0200)	Write the name of the VNIC interface to this
+				file to create primary connection for VNIC
+				interface through given HCA and port, once all
+				parameters required for connection establishment
+				has been already set into primary_path of the
+				VNIC interface.
+
+	create_secondary(0200)	Write the name of the VNIC interface to this
+				file to create secondary connection for VNIC
+				interface through given HCA and port, once all
+				parameters required for connection establishment
+				has been already set into secondary_path of the
+				VNIC interface.
+
+/sys/class/infiniband_qlgc_vnic/interfaces/<VNIC-interface-name>/stats
+
+	carrier_losses		(0444)	No of times the carrier loss was
+					detected for this VNIC interface.
+
+	connection_time		(0444)	Amount of time this VNIC was in 
+					connected state.
+
+	disconnects		(0444)	No of times this VNIC interface got
+					disconnected from EVIC.
+
+	failed_xmits		(0444)	No of transmits over this VNIC interface
+					that have failed.
+
+	lifetime		(0444)	Amount of time elapsed since this VNIC
+					interface was created.
+
+	multicast_recvs		(0444)	No of IB multicast packets received over
+					this VNIC interface.
+
+	recvs			(0444)	Total no of packets received on this
+					VNIC interface.
+
+	xmits			(0444)	Total no of packets that have been
+					successfully transmitted over this VNIC
+					interface.
+
+	total_recv_time		(0444)	Amount of time taken in receive
+					processing, from the time driver got the
+					receive completion till the skb was sent
+					to kernel.
+
+	total_xmit_time		(0444)	Amount of time taken in transmit
+					processing, from the time skb was
+					received from kernel till a RDMA write
+					was done for it.
+
+	total_disconn_time	(0444)	Amount of time this VNIC interface was/is
+					in disconnected state.
+
+	total_carrier_loss_time	(0444)	Amount of time there was no carrier
+					present for this VNIC interface.
+
+Example:
+--------
+
+QLogic VNIC sysfs interface can be used directly to create a VNIC interface.
+
+# echo the name of new VNIC interface to create_vnic
+echo -n veth1 > /sys/class/infiniband_qlgc_vnic/interfaces/create_vnic
+
+# echo parameters to configure the VNIC interface. Some of these are 
+# interface level parameters which needs to be passed only once per VNIC
+# interface.
+
+echo -n true  > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/rx_csum
+echo -n false > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/tx_csum
+echo -n false > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/multicast
+
+echo -n 00066a01de000037 		 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/ioc_guid
+echo -n fe8000000000000100066a11de000037 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/dgid
+echo -n ffff 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/pkey
+echo -n 0 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/instance
+echo -n 100 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/heartbeat
+string="EVIC in Chassis 0x00066a00db000010, Slot 4, Ioc 1"
+echo -n $string 			 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/primary_path/ioc_string
+
+# Trigger the connection establishment process for the path by choosing required
+# HCA and IB port combination.
+
+echo -n veth1 > /sys/class/infiniband_qlgc_vnic/vnic-mlx4_0-1/create_primary
+
+# In case of failover configuration, pass the parameters of the failover
+# connection to the driver and trigger its connection establishment
+# process.
+
+echo -n 00066a01de000037 		 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/ioc_guid
+echo -n fe8000000000000100066a11de000037 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/dgid
+echo -n ffff 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/pkey
+echo -n 1 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/instance
+echo -n 100 				 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/heartbeat
+string="EVIC in Chassis 0x00066a00db000010, Slot 4, Ioc 1"
+echo -n $string 			 > /sys/class/infiniband_qlgc_vnic/interfaces/veth1/secondary_path/ioc_string
+
+echo -n veth1 > /sys/class/infiniband_qlgc_vnic/vnic-mlx4_0-2/create_secondary
+
+# An interface can be deleted by echoing the name of the interface to be deleted
+# to delete_vnic file
+echo -n veth1 > /sys/class/infiniband_qlgc_vnic/interfaces/delete_vnic
