From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] hdlc: Remove typedefs from struct names
Date: Sat, 9 Aug 2014 22:17:16 +0530
Message-ID: <20140809164716.GA21548@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Linux kernel coding style guidelines suggest not using typedefs
for structure types. This patch gets rid of the typedefs for
fr_hdr and pvc_device. Also, the names of the structs are changed to
drop the _t, to make the name look less typedef-like.

The following Coccinelle semantic patch detects the case fr_hdr and a
similar one detects the case for pvc_device.

@tn1@
type td;
@@

typedef struct { ... } td;

@script:python tf@
td << tn1.td;
tdres;
@@

coccinelle.tdres = td;

@@
type tn1.td;
identifier tf.tdres;
@@

-typedef
 struct
+  tdres
   { ... }
-td
 ;

@@
type tn1.td;
identifier tf.tdres;
@@

-td
+ struct tdres

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
To send to: Krzysztof Halasa <khc@pm.waw.pl>,netdev@vger.kernel.org,linux-kernel@vger.kernel.org
 drivers/net/wan/hdlc_fr.c | 63 ++++++++++++++++++++++++-----------------------
 1 file changed, 32 insertions(+), 31 deletions(-)

diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 7cc64ea..e5c7e61 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -90,7 +90,7 @@
 #define LMI_ANSI_LENGTH		  14
 
 
-typedef struct {
+struct fr_hdr {
 #if defined(__LITTLE_ENDIAN_BITFIELD)
 	unsigned ea1:	1;
 	unsigned cr:	1;
@@ -112,14 +112,14 @@ typedef struct {
 	unsigned de:	1;
 	unsigned ea2:	1;
 #endif
-}__packed fr_hdr;
+} __packed;
 
 
-typedef struct pvc_device_struct {
+struct pvc_device {
 	struct net_device *frad;
 	struct net_device *main;
 	struct net_device *ether;	/* bridged Ethernet interface	*/
-	struct pvc_device_struct *next;	/* Sorted in ascending DLCI order */
+	struct pvc_device *next;	/* Sorted in ascending DLCI order */
 	int dlci;
 	int open_count;
 
@@ -132,11 +132,11 @@ typedef struct pvc_device_struct {
 		unsigned int becn: 1;
 		unsigned int bandwidth;	/* Cisco LMI reporting only */
 	}state;
-}pvc_device;
+};
 
 struct frad_state {
 	fr_proto settings;
-	pvc_device *first_pvc;
+	struct pvc_device *first_pvc;
 	int dce_pvc_count;
 
 	struct timer_list timer;
@@ -174,9 +174,9 @@ static inline struct frad_state* state(hdlc_device *hdlc)
 }
 
 
-static inline pvc_device* find_pvc(hdlc_device *hdlc, u16 dlci)
+static inline struct pvc_device *find_pvc(hdlc_device *hdlc, u16 dlci)
 {
-	pvc_device *pvc = state(hdlc)->first_pvc;
+	struct pvc_device *pvc = state(hdlc)->first_pvc;
 
 	while (pvc) {
 		if (pvc->dlci == dlci)
@@ -190,10 +190,10 @@ static inline pvc_device* find_pvc(hdlc_device *hdlc, u16 dlci)
 }
 
 
-static pvc_device* add_pvc(struct net_device *dev, u16 dlci)
+static struct pvc_device *add_pvc(struct net_device *dev, u16 dlci)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
-	pvc_device *pvc, **pvc_p = &state(hdlc)->first_pvc;
+	struct pvc_device *pvc, **pvc_p = &state(hdlc)->first_pvc;
 
 	while (*pvc_p) {
 		if ((*pvc_p)->dlci == dlci)
@@ -203,7 +203,7 @@ static pvc_device* add_pvc(struct net_device *dev, u16 dlci)
 		pvc_p = &(*pvc_p)->next;
 	}
 
-	pvc = kzalloc(sizeof(pvc_device), GFP_ATOMIC);
+	pvc = kzalloc(sizeof(*pvc), GFP_ATOMIC);
 #ifdef DEBUG_PVC
 	printk(KERN_DEBUG "add_pvc: allocated pvc %p, frad %p\n", pvc, dev);
 #endif
@@ -218,13 +218,13 @@ static pvc_device* add_pvc(struct net_device *dev, u16 dlci)
 }
 
 
-static inline int pvc_is_used(pvc_device *pvc)
+static inline int pvc_is_used(struct pvc_device *pvc)
 {
 	return pvc->main || pvc->ether;
 }
 
 
-static inline void pvc_carrier(int on, pvc_device *pvc)
+static inline void pvc_carrier(int on, struct pvc_device *pvc)
 {
 	if (on) {
 		if (pvc->main)
@@ -246,11 +246,11 @@ static inline void pvc_carrier(int on, pvc_device *pvc)
 
 static inline void delete_unused_pvcs(hdlc_device *hdlc)
 {
-	pvc_device **pvc_p = &state(hdlc)->first_pvc;
+	struct pvc_device **pvc_p = &state(hdlc)->first_pvc;
 
 	while (*pvc_p) {
 		if (!pvc_is_used(*pvc_p)) {
-			pvc_device *pvc = *pvc_p;
+			struct pvc_device *pvc = *pvc_p;
 #ifdef DEBUG_PVC
 			printk(KERN_DEBUG "freeing unused pvc: %p\n", pvc);
 #endif
@@ -263,7 +263,8 @@ static inline void delete_unused_pvcs(hdlc_device *hdlc)
 }
 
 
-static inline struct net_device** get_dev_p(pvc_device *pvc, int type)
+static inline struct net_device **get_dev_p(struct pvc_device *pvc,
+					    int type)
 {
 	if (type == ARPHRD_ETHER)
 		return &pvc->ether;
@@ -342,7 +343,7 @@ static int fr_hard_header(struct sk_buff **skb_p, u16 dlci)
 
 static int pvc_open(struct net_device *dev)
 {
-	pvc_device *pvc = dev->ml_priv;
+	struct pvc_device *pvc = dev->ml_priv;
 
 	if ((pvc->frad->flags & IFF_UP) == 0)
 		return -EIO;  /* Frad must be UP in order to activate PVC */
@@ -362,7 +363,7 @@ static int pvc_open(struct net_device *dev)
 
 static int pvc_close(struct net_device *dev)
 {
-	pvc_device *pvc = dev->ml_priv;
+	struct pvc_device *pvc = dev->ml_priv;
 
 	if (--pvc->open_count == 0) {
 		hdlc_device *hdlc = dev_to_hdlc(pvc->frad);
@@ -381,7 +382,7 @@ static int pvc_close(struct net_device *dev)
 
 static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	pvc_device *pvc = dev->ml_priv;
+	struct pvc_device *pvc = dev->ml_priv;
 	fr_proto_pvc_info info;
 
 	if (ifr->ifr_settings.type == IF_GET_PROTO) {
@@ -409,7 +410,7 @@ static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static netdev_tx_t pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pvc_device *pvc = dev->ml_priv;
+	struct pvc_device *pvc = dev->ml_priv;
 
 	if (pvc->state.active) {
 		if (dev->type == ARPHRD_ETHER) {
@@ -444,7 +445,7 @@ static netdev_tx_t pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static inline void fr_log_dlci_active(pvc_device *pvc)
+static inline void fr_log_dlci_active(struct pvc_device *pvc)
 {
 	netdev_info(pvc->frad, "DLCI %d [%s%s%s]%s %s\n",
 		    pvc->dlci,
@@ -469,7 +470,7 @@ static void fr_lmi_send(struct net_device *dev, int fullrep)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	struct sk_buff *skb;
-	pvc_device *pvc = state(hdlc)->first_pvc;
+	struct pvc_device *pvc = state(hdlc)->first_pvc;
 	int lmi = state(hdlc)->settings.lmi;
 	int dce = state(hdlc)->settings.dce;
 	int len = lmi == LMI_ANSI ? LMI_ANSI_LENGTH : LMI_CCITT_CISCO_LENGTH;
@@ -566,7 +567,7 @@ static void fr_lmi_send(struct net_device *dev, int fullrep)
 static void fr_set_link_state(int reliable, struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
-	pvc_device *pvc = state(hdlc)->first_pvc;
+	struct pvc_device *pvc = state(hdlc)->first_pvc;
 
 	state(hdlc)->reliable = reliable;
 	if (reliable) {
@@ -652,7 +653,7 @@ static void fr_timer(unsigned long arg)
 static int fr_lmi_recv(struct net_device *dev, struct sk_buff *skb)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
-	pvc_device *pvc;
+	struct pvc_device *pvc;
 	u8 rxseq, txseq;
 	int lmi = state(hdlc)->settings.lmi;
 	int dce = state(hdlc)->settings.dce;
@@ -869,10 +870,10 @@ static int fr_rx(struct sk_buff *skb)
 {
 	struct net_device *frad = skb->dev;
 	hdlc_device *hdlc = dev_to_hdlc(frad);
-	fr_hdr *fh = (fr_hdr*)skb->data;
+	struct fr_hdr *fh = (struct fr_hdr *)skb->data;
 	u8 *data = skb->data;
 	u16 dlci;
-	pvc_device *pvc;
+	struct pvc_device *pvc;
 	struct net_device *dev = NULL;
 
 	if (skb->len <= 4 || fh->ea1 || data[2] != FR_UI)
@@ -1028,7 +1029,7 @@ static void fr_stop(struct net_device *dev)
 static void fr_close(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
-	pvc_device *pvc = state(hdlc)->first_pvc;
+	struct pvc_device *pvc = state(hdlc)->first_pvc;
 
 	while (pvc) {		/* Shutdown all PVCs for this FRAD */
 		if (pvc->main)
@@ -1060,7 +1061,7 @@ static const struct net_device_ops pvc_ops = {
 static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 {
 	hdlc_device *hdlc = dev_to_hdlc(frad);
-	pvc_device *pvc;
+	struct pvc_device *pvc;
 	struct net_device *dev;
 	int used;
 
@@ -1117,7 +1118,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 
 static int fr_del_pvc(hdlc_device *hdlc, unsigned int dlci, int type)
 {
-	pvc_device *pvc;
+	struct pvc_device *pvc;
 	struct net_device *dev;
 
 	if ((pvc = find_pvc(hdlc, dlci)) == NULL)
@@ -1145,13 +1146,13 @@ static int fr_del_pvc(hdlc_device *hdlc, unsigned int dlci, int type)
 static void fr_destroy(struct net_device *frad)
 {
 	hdlc_device *hdlc = dev_to_hdlc(frad);
-	pvc_device *pvc = state(hdlc)->first_pvc;
+	struct pvc_device *pvc = state(hdlc)->first_pvc;
 	state(hdlc)->first_pvc = NULL; /* All PVCs destroyed */
 	state(hdlc)->dce_pvc_count = 0;
 	state(hdlc)->dce_changed = 1;
 
 	while (pvc) {
-		pvc_device *next = pvc->next;
+		struct pvc_device *next = pvc->next;
 		/* destructors will free_netdev() main and ether */
 		if (pvc->main)
 			unregister_netdevice(pvc->main);
-- 
1.9.1
