From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Tue, 22 Apr 2008 16:50:48 +0300
Message-ID: <480DED38.3080900@teltonika.lt>
References: <20080417214719.GF17664@kroah.com> <480BE815.2000409@teltonika.lt> <480CB8C2.9090902@teltonika.lt> <480DA2CA.8090705@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040201080402070707010600"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <480DA2CA.8090705-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040201080402070707010600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Incremental patch.
- remove not needed variable initializations
- remove hso_net_get_stats, because by default identical
   internal_stats function from net/core/dev.c is used.
- remove not needed memset(hso_net, 0, sizeof(*hso_net)),
   because memory is allocated with kzalloc

--------------040201080402070707010600
Content-Type: text/x-patch;
 name="hso_not_needed.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_not_needed.patch"

--- linux-2.6-hso-my/drivers/net/usb/hso.c.orig	2008-04-22 11:16:01.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-22 16:37:31.000000000 +0300
@@ -547,7 +547,7 @@ static struct hso_serial *get_serial_by_
 
 static struct hso_serial *get_serial_by_index(unsigned index)
 {
-	struct hso_serial *serial = NULL;
+	struct hso_serial *serial;
 	unsigned long flags;
 
 	if (!serial_table[index])
@@ -561,7 +561,7 @@ static struct hso_serial *get_serial_by_
 
 static int get_free_serial_index(void)
 {
-	int index = 0;
+	int index;
 	unsigned long flags;
 
 	spin_lock_irqsave(&serial_table_lock, flags);
@@ -591,7 +591,7 @@ static void set_serial_by_index(unsigned
 /* log a meaningfull explanation of an USB status */
 static void log_usb_status(int status, const char *function)
 {
-	char *explanation = NULL;
+	char *explanation;
 
 	switch (status) {
 	case -ENODEV:
@@ -630,10 +630,9 @@ static void log_usb_status(int status, c
 static int hso_proc_options(char *buf, char **start, off_t offset, int count,
 			    int *eof, void *data)
 {
-	int len = 0;
+	int len;
 	/* get the module parameters */
-	len +=
-	    snprintf(buf + len, count - len, "Version: %s\n", DRIVER_VERSION);
+	len = snprintf(buf, count, "Version: %s\n", DRIVER_VERSION);
 	len += snprintf(buf + len, count - len, "debug: 0x%02x\n", debug);
 	len += snprintf(buf + len, count - len, "procfs: 0x%02x\n", procfs);
 	len +=
@@ -647,9 +646,9 @@ static int hso_proc_options(char *buf, c
 static int hso_proc_port_info(char *buf, char **start, off_t offset, int count,
 			      int *eof, void *data)
 {
-	int len = 0;
+	int len;
 	struct hso_device *hso_dev = (struct hso_device *)data;
-	char *port_name = NULL;
+	char *port_name;
 
 	D1("count: %d", count);
 
@@ -689,7 +688,7 @@ static int hso_proc_port_info(char *buf,
 		break;
 	}
 
-	len += snprintf(buf + len, count - len, "%s\n", port_name);
+	len = snprintf(buf, count, "%s\n", port_name);
 
 	/* return the device id to the user, for use in scripts for autopm */
 	len +=
@@ -782,7 +781,7 @@ static void write_bulk_callback(struct u
 static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	struct hso_net *odev = netdev_priv(net);
-	int result = 0;
+	int result;
 
 	/* Tell the kernel, "No more frames 'til we are done with this one." */
 	netif_stop_queue(net);
@@ -843,11 +842,6 @@ static struct ethtool_ops ops = {
 	.get_link = ethtool_op_get_link
 };
 
-static struct net_device_stats *hso_net_get_stats(struct net_device *net)
-{
-	return &net->stats;
-}
-
 /* called when a packet did not ack after watchdogtimeout */
 static void hso_net_tx_timeout(struct net_device *net)
 {
@@ -872,11 +866,11 @@ static void hso_net_tx_timeout(struct ne
 static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 			unsigned int count, unsigned char is_eop)
 {
-	unsigned short temp_bytes = 0;
+	unsigned short temp_bytes;
 	unsigned short buffer_offset = 0;
-	unsigned short frame_len = 0;
-	unsigned char *tmp_rx_buf = NULL;
-	struct ethhdr *eth_head = NULL;
+	unsigned short frame_len;
+	unsigned char *tmp_rx_buf;
+	struct ethhdr *eth_head;
 
 	/* log if needed */
 	D1("Rx %d bytes", count);
@@ -1027,8 +1021,8 @@ static void packetizeRx(struct hso_net *
 static void read_bulk_callback(struct urb *urb)
 {
 	struct hso_net *odev = urb->context;
-	struct net_device *net = NULL;
-	int result = 0;
+	struct net_device *net;
+	int result;
 	int status = urb->status;
 
 	/* is al ok?  (Filip: Who's Al ?) */
@@ -1248,7 +1242,7 @@ static int hso_serial_write(struct tty_s
 			    int count)
 {
 	struct hso_serial *serial = get_serial_by_tty(tty);
-	int space = 0, tx_bytes = 0;
+	int space, tx_bytes;
 	unsigned long flags;
 
 	/* sanity check */
@@ -1281,7 +1275,7 @@ out:
 static int hso_serial_write_room(struct tty_struct *tty)
 {
 	struct hso_serial *serial = get_serial_by_tty(tty);
-	int room = 0;
+	int room;
 	unsigned long flags;
 
 	spin_lock_irqsave(&serial->serial_lock, flags);
@@ -1316,7 +1310,7 @@ static void hso_serial_set_termios(struc
 static int hso_serial_chars_in_buffer(struct tty_struct *tty)
 {
 	struct hso_serial *serial = get_serial_by_tty(tty);
-	int chars = 0;
+	int chars;
 	unsigned long flags;
 
 	/* sanity check */
@@ -1332,7 +1326,7 @@ static int hso_serial_chars_in_buffer(st
 
 static int hso_serial_tiocmget(struct tty_struct *tty, struct file *file)
 {
-	unsigned int value = 0;
+	unsigned int value;
 	struct hso_serial *serial = get_serial_by_tty(tty);
 	unsigned long flags;
 
@@ -1392,7 +1386,7 @@ static int hso_serial_tiocmset(struct tt
 /* starts a transmit */
 static void hso_kick_transmit(struct hso_serial *serial)
 {
-	u8 *temp = NULL;
+	u8 *temp;
 	unsigned long flags;
 	int res;
 
@@ -1430,8 +1424,8 @@ static int mux_device_request(struct hso
 			      struct usb_ctrlrequest *ctrl_req,
 			      u8 *ctrl_urb_data, u32 size)
 {
-	int result = 0;
-	int pipe = -1;
+	int result;
+	int pipe;
 
 	/* Sanity check */
 	if (!serial || !ctrl_urb || !ctrl_req) {
@@ -1512,10 +1506,10 @@ static int hso_mux_serial_read(struct hs
 static void intr_callback(struct urb *urb)
 {
 	struct hso_shared_int *shared_int = urb->context;
-	struct hso_serial *serial = NULL;
-	unsigned char *port_req = NULL;
+	struct hso_serial *serial;
+	unsigned char *port_req;
 	int status = urb->status;
-	int i = 0;
+	int i;
 
 	usb_mark_last_busy(urb->dev);
 
@@ -1602,7 +1596,7 @@ static void hso_std_serial_write_bulk_ca
 static int hso_std_serial_write_data(struct hso_serial *serial)
 {
 	int count = serial->tx_data_count;
-	int result = 0;
+	int result;
 
 	usb_fill_bulk_urb(serial->tx_urb,
 			  serial->parent->usb,
@@ -1626,7 +1620,7 @@ static int hso_std_serial_write_data(str
 static void ctrl_callback(struct urb *urb)
 {
 	struct hso_serial *serial = urb->context;
-	struct usb_ctrlrequest *req = NULL;
+	struct usb_ctrlrequest *req;
 	int status = urb->status;
 
 	/* sanity check */
@@ -1692,7 +1686,7 @@ static void put_rxbuf_data(struct urb *u
 static void hso_std_serial_read_bulk_callback(struct urb *urb)
 {
 	struct hso_serial *serial = urb->context;
-	int result = 0;
+	int result;
 	int status = urb->status;
 
 	/* sanity check */
@@ -1758,7 +1752,7 @@ static void hso_std_serial_read_bulk_cal
 
 static void hso_log_port(struct hso_device *hso_dev)
 {
-	char *port_type = NULL;
+	char *port_type;
 	char port_dev[20];
 
 	switch (hso_dev->port_spec & HSO_PORT_MASK) {
@@ -1958,7 +1952,7 @@ static void hso_serial_common_free(struc
 static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
 				    int rx_size, int tx_size)
 {
-	struct device *dev = NULL;
+	struct device *dev;
 	int minor;
 	int i;
 
@@ -2107,8 +2101,6 @@ static void hso_net_init(struct net_devi
 {
 	struct hso_net *hso_net = netdev_priv(net);
 
-	/* initialize to zero */
-	memset(hso_net, 0, sizeof(*hso_net));
 	D1("sizeof hso_net is %d", (int)sizeof(*hso_net));
 
 	/* most of the setup is done by standard function */
@@ -2118,7 +2110,6 @@ static void hso_net_init(struct net_devi
 	net->open = hso_net_open;
 	net->stop = hso_net_close;
 	net->hard_start_xmit = hso_net_start_xmit;
-	net->get_stats = hso_net_get_stats;
 	net->tx_timeout = hso_net_tx_timeout;
 	net->watchdog_timeo = HSO_NET_TX_TIMEOUT;
 	net->flags |= IFF_NOARP;
@@ -2137,8 +2128,7 @@ static void set_ethernet_addr(struct hso
 {
 	unsigned char mac_addr[6];
 	unsigned char dummy_mac[6];
-	int i = 0;
-	int len = 0;
+	int i, len;
 	unsigned char buffer[13];
 
 	/* we can't fail, therefor we use a random macaddress */
@@ -2197,9 +2187,9 @@ static int add_net_device(struct hso_dev
 static struct hso_device *hso_create_net_device(struct usb_interface *interface)
 {
 	int result, i;
-	struct net_device *net = NULL;
-	struct hso_net *hso_net = NULL;
-	struct hso_device *hso_dev = NULL;
+	struct net_device *net;
+	struct hso_net *hso_net;
+	struct hso_device *hso_dev;
 
 	hso_dev = hso_create_device(interface, HSO_INTF_MUX | HSO_PORT_NETWORK);
 	if (!hso_dev)
@@ -2319,8 +2309,8 @@ static void hso_free_serial_device(struc
 static struct hso_device *hso_create_bulk_serial_device(
 			struct usb_interface *interface, int port)
 {
-	struct hso_device *hso_dev = NULL;
-	struct hso_serial *serial = NULL;
+	struct hso_device *hso_dev;
+	struct hso_serial *serial;
 	char device_name[20];
 	int num_urbs;
 
@@ -2391,12 +2381,12 @@ struct hso_device *hso_create_mux_serial
 						int port,
 						struct hso_shared_int *mux)
 {
-	struct hso_device *hso_dev = NULL;
-	struct hso_serial *serial = NULL;
+	struct hso_device *hso_dev;
+	struct hso_serial *serial;
 	char device_name[20];
-	int port_spec = 0;
+	int port_spec;
 
-	port_spec |= HSO_INTF_MUX;
+	port_spec = HSO_INTF_MUX;
 	port_spec &= ~HSO_PORT_MASK;
 
 	port_spec |= hso_mux_to_port(port);
@@ -2506,7 +2496,7 @@ static int hso_get_config_data(struct us
 	struct usb_device *usbdev = interface_to_usbdev(interface);
 	u8 config_data[17];
 	u32 if_num = interface->altsetting->desc.bInterfaceNumber;
-	s32 result = 0;
+	s32 result;
 
 	if (usb_control_msg(usbdev, usb_rcvctrlpipe(usbdev, 0),
 			    0x86, 0xC0, 0, 0, config_data, 17,
@@ -2588,8 +2578,8 @@ static int hso_probe(struct usb_interfac
 	int mux, i, if_num, port_spec;
 	unsigned char port_mask;
 	char *rfkn;
-	struct hso_device *hso_dev = NULL;
-	struct hso_shared_int *shared_int = NULL;
+	struct hso_device *hso_dev;
+	struct hso_shared_int *shared_int;
 	struct hso_device *tmp_dev = NULL;
 
 	if_num = interface->altsetting->desc.bInterfaceNumber;
@@ -2760,7 +2750,7 @@ static int hso_put_activity(struct hso_d
 /* called by kernel when we need to suspend device */
 static int hso_suspend(struct usb_interface *iface, pm_message_t message)
 {
-	int i, result = 0;
+	int i, result;
 
 	/* Stop all serial ports */
 	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
@@ -2872,7 +2862,7 @@ static struct usb_endpoint_descriptor *h
 {
 	int i;
 	struct usb_host_interface *iface = intf->cur_altsetting;
-	struct usb_endpoint_descriptor *endp = NULL;
+	struct usb_endpoint_descriptor *endp;
 
 	for (i = 0; i < iface->desc.bNumEndpoints; i++) {
 		endp = &iface->endpoint[i].desc;
@@ -2951,8 +2941,8 @@ static struct usb_driver hso_driver = {
 
 static int __init hso_init(void)
 {
-	int i = 0;
-	int result = 0;
+	int i;
+	int result;
 
 	/* put it in the log */
 	printk(KERN_INFO "hso: %s\n", version);

--------------040201080402070707010600--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
