From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/6] IrDA: IrNET code indentation
Date: Wed, 14 Mar 2007 21:23:55 +0200
Message-ID: <20070314192355.GE3397@sortiz.org>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The IrNET code was not exactly following the kernel coding style...
No functional changes, just an indentation fix.

Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 net/irda/irnet/irnet.h      |  189 ++--
 net/irda/irnet/irnet_irda.c | 2572 +++++++++++++++++++++----------------------
 net/irda/irnet/irnet_irda.h |  162 +--
 net/irda/irnet/irnet_ppp.c  | 1658 ++++++++++++++--------------
 net/irda/irnet/irnet_ppp.h  |   86 +-
 5 files changed, 2262 insertions(+), 2405 deletions(-)

diff --git a/net/irda/irnet/irnet.h b/net/irda/irnet/irnet.h
index 873ae18..44b58a6 100644
--- a/net/irda/irnet/irnet.h
+++ b/net/irda/irnet/irnet.h
@@ -394,109 +394,105 @@
  * to be called "self", and if it is borrowed from the PPP driver it is
  * "ap". Apart from that, it's exactly the same structure ;-)
  */
-typedef struct irnet_socket
-{
-  /* ------------------- Instance management ------------------- */
-  /* We manage a linked list of IrNET socket instances */
-  irda_queue_t		q;		/* Must be first - for hasbin */
-  int			magic;		/* Paranoia */
-
-  /* --------------------- FileSystem part --------------------- */
-  /* "pppd" interact directly with us on a /dev/ file */
-  struct file *		file;		/* File descriptor of this instance */
-  /* TTY stuff - to keep "pppd" happy */
-  struct termios	termios;	/* Various tty flags */
-  /* Stuff for the control channel */
-  int			event_index;	/* Last read in the event log */
-
-  /* ------------------------- PPP part ------------------------- */
-  /* We interface directly to the ppp_generic driver in the kernel */
-  int			ppp_open;	/* registered with ppp_generic */
-  struct ppp_channel	chan;		/* Interface to generic ppp layer */
-
-  int			mru;		/* Max size of PPP payload */
-  u32			xaccm[8];	/* Asynchronous character map (just */
-  u32			raccm;		/* to please pppd - dummy) */
-  unsigned int		flags;		/* PPP flags (compression, ...) */
-  unsigned int		rbits;		/* Unused receive flags ??? */
-
-  /* ------------------------ IrTTP part ------------------------ */
-  /* We create a pseudo "socket" over the IrDA tranport */
-  unsigned long		ttp_open;	/* Set when IrTTP is ready */
-  unsigned long		ttp_connect;	/* Set when IrTTP is connecting */
-  struct tsap_cb *	tsap;		/* IrTTP instance (the connection) */
-
-  char			rname[NICKNAME_MAX_LEN + 1];
-					/* IrDA nickname of destination */
-  __u32			rdaddr;		/* Requested peer IrDA address */
-  __u32			rsaddr;		/* Requested local IrDA address */
-  __u32			daddr;		/* actual peer IrDA address */
-  __u32			saddr;		/* my local IrDA address */
-  __u8			dtsap_sel;	/* Remote TSAP selector */
-  __u8			stsap_sel;	/* Local TSAP selector */
-
-  __u32			max_sdu_size_rx;/* Socket parameters used for IrTTP */
-  __u32			max_sdu_size_tx;
-  __u32			max_data_size;
-  __u8			max_header_size;
-  LOCAL_FLOW		tx_flow;	/* State of the Tx path in IrTTP */
-
-  /* ------------------- IrLMP and IrIAS part ------------------- */
-  /* Used for IrDA Discovery and socket name resolution */
-  void *		ckey;		/* IrLMP client handle */
-  __u16			mask;		/* Hint bits mask (filter discov.)*/
-  int			nslots;		/* Number of slots for discovery */
-
-  struct iriap_cb *	iriap;		/* Used to query remote IAS */
-  int			errno;		/* status of the IAS query */
-
-  /* -------------------- Discovery log part -------------------- */
-  /* Used by initial discovery on the control channel
-   * and by irnet_discover_daddr_and_lsap_sel() */
-  struct irda_device_info *discoveries;	/* Copy of the discovery log */
-  int			disco_index;	/* Last read in the discovery log */
-  int			disco_number;	/* Size of the discovery log */
+typedef struct irnet_socket {
+	/* ------------------- Instance management ------------------- */
+	/* We manage a linked list of IrNET socket instances */
+	irda_queue_t q;		/* Must be first - for hasbin */
+	int magic;		/* Paranoia */
+
+	/* --------------------- FileSystem part --------------------- */
+	/* "pppd" interact directly with us on a /dev/ file */
+	struct file *file;	/* File descriptor of this instance */
+	/* TTY stuff - to keep "pppd" happy */
+	struct termios termios;	/* Various tty flags */
+	/* Stuff for the control channel */
+	int event_index;	/* Last read in the event log */
+
+	/* ------------------------- PPP part ------------------------- */
+	/* We interface directly to the ppp_generic driver in the kernel */
+	int ppp_open;		/* registered with ppp_generic */
+	struct ppp_channel chan;	/* Interface to generic ppp layer */
+
+	int mru;		/* Max size of PPP payload */
+	u32 xaccm[8];		/* Asynchronous character map (just */
+	u32 raccm;		/* to please pppd - dummy) */
+	unsigned int flags;	/* PPP flags (compression, ...) */
+	unsigned int rbits;	/* Unused receive flags ??? */
+
+	/* ------------------------ IrTTP part ------------------------ */
+	/* We create a pseudo "socket" over the IrDA tranport */
+	unsigned long ttp_open;	/* Set when IrTTP is ready */
+	unsigned long ttp_connect;	/* Set when IrTTP is connecting */
+	struct tsap_cb *tsap;	/* IrTTP instance (the connection) */
+
+	char rname[NICKNAME_MAX_LEN + 1];
+	/* IrDA nickname of destination */
+	__u32 rdaddr;		/* Requested peer IrDA address */
+	__u32 rsaddr;		/* Requested local IrDA address */
+	__u32 daddr;		/* actual peer IrDA address */
+	__u32 saddr;		/* my local IrDA address */
+	__u8 dtsap_sel;		/* Remote TSAP selector */
+	__u8 stsap_sel;		/* Local TSAP selector */
+
+	__u32 max_sdu_size_rx;	/* Socket parameters used for IrTTP */
+	__u32 max_sdu_size_tx;
+	__u32 max_data_size;
+	__u8 max_header_size;
+	LOCAL_FLOW tx_flow;	/* State of the Tx path in IrTTP */
+
+	/* ------------------- IrLMP and IrIAS part ------------------- */
+	/* Used for IrDA Discovery and socket name resolution */
+	void *ckey;		/* IrLMP client handle */
+	__u16 mask;		/* Hint bits mask (filter discov.) */
+	int nslots;		/* Number of slots for discovery */
+
+	struct iriap_cb *iriap;	/* Used to query remote IAS */
+	int errno;		/* status of the IAS query */
+
+	/* -------------------- Discovery log part -------------------- */
+	/* Used by initial discovery on the control channel
+	 * and by irnet_discover_daddr_and_lsap_sel() */
+	struct irda_device_info *discoveries;	/* Copy of the discovery log */
+	int disco_index;	/* Last read in the discovery log */
+	int disco_number;	/* Size of the discovery log */
 
 } irnet_socket;
 
 /*
  * This is the various event that we will generate on the control channel
  */
-typedef enum irnet_event
-{
-  IRNET_DISCOVER,		/* New IrNET node discovered */
-  IRNET_EXPIRE,			/* IrNET node expired */
-  IRNET_CONNECT_TO,		/* IrNET socket has connected to other node */
-  IRNET_CONNECT_FROM,		/* Other node has connected to IrNET socket */
-  IRNET_REQUEST_FROM,		/* Non satisfied connection request */
-  IRNET_NOANSWER_FROM,		/* Failed connection request */
-  IRNET_BLOCKED_LINK,		/* Link (IrLAP) is blocked for > 3s */
-  IRNET_DISCONNECT_FROM,	/* IrNET socket has disconnected */
-  IRNET_DISCONNECT_TO		/* Closing IrNET socket */
+typedef enum irnet_event {
+	IRNET_DISCOVER,		/* New IrNET node discovered */
+	IRNET_EXPIRE,		/* IrNET node expired */
+	IRNET_CONNECT_TO,	/* IrNET socket has connected to other node */
+	IRNET_CONNECT_FROM,	/* Other node has connected to IrNET socket */
+	IRNET_REQUEST_FROM,	/* Non satisfied connection request */
+	IRNET_NOANSWER_FROM,	/* Failed connection request */
+	IRNET_BLOCKED_LINK,	/* Link (IrLAP) is blocked for > 3s */
+	IRNET_DISCONNECT_FROM,	/* IrNET socket has disconnected */
+	IRNET_DISCONNECT_TO	/* Closing IrNET socket */
 } irnet_event;
 
 /*
  * This is the storage for an event and its arguments
  */
-typedef struct irnet_log
-{
-  irnet_event	event;
-  int		unit;
-  __u32		saddr;
-  __u32		daddr;
-  char		name[NICKNAME_MAX_LEN + 1];	/* 21 + 1 */
-  __u16_host_order hints;			/* Discovery hint bits */
+typedef struct irnet_log {
+	irnet_event event;
+	int unit;
+	__u32 saddr;
+	__u32 daddr;
+	char name[NICKNAME_MAX_LEN + 1];	/* 21 + 1 */
+	__u16_host_order hints;	/* Discovery hint bits */
 } irnet_log;
 
 /*
  * This is the storage for all events and related stuff...
  */
-typedef struct irnet_ctrl_channel
-{
-  irnet_log	log[IRNET_MAX_EVENTS];	/* Event log */
-  int		index;		/* Current index in log */
-  spinlock_t	spinlock;	/* Serialize access to the event log */
-  wait_queue_head_t	rwait;	/* processes blocked on read (or poll) */
+typedef struct irnet_ctrl_channel {
+	irnet_log log[IRNET_MAX_EVENTS];	/* Event log */
+	int index;		 /* Current index in log */
+	spinlock_t spinlock;	 /* Serialize access to the event log */
+	wait_queue_head_t rwait; /* processes blocked on read (or poll) */
 } irnet_ctrl_channel;
 
 /**************************** PROTOTYPES ****************************/
@@ -506,20 +502,15 @@ typedef struct irnet_ctrl_channel
  */
 
 /* -------------------------- IRDA PART -------------------------- */
-extern int
-	irda_irnet_create(irnet_socket *);	/* Initialise a IrNET socket */
-extern int
-	irda_irnet_connect(irnet_socket *);	/* Try to connect over IrDA */
-extern void
-	irda_irnet_destroy(irnet_socket *);	/* Teardown  a IrNET socket */
-extern int
-	irda_irnet_init(void);		/* Initialise IrDA part of IrNET */
-extern void
-	irda_irnet_cleanup(void);	/* Teardown IrDA part of IrNET */
+extern int irda_irnet_create(irnet_socket *);	/* Initialise a IrNET socket */
+extern int irda_irnet_connect(irnet_socket *);	/* Try to connect over IrDA */
+extern void irda_irnet_destroy(irnet_socket *);	/* Teardown  a IrNET socket */
+extern int irda_irnet_init(void);	/* Initialise IrDA part of IrNET */
+extern void irda_irnet_cleanup(void);	/* Teardown IrDA part of IrNET */
 
 /**************************** VARIABLES ****************************/
 
 /* Control channel stuff - allocated in irnet_irda.h */
-extern struct irnet_ctrl_channel	irnet_events;
+extern struct irnet_ctrl_channel irnet_events;
 
-#endif /* IRNET_H */
+#endif				/* IRNET_H */
diff --git a/net/irda/irnet/irnet_irda.c b/net/irda/irnet/irnet_irda.c
index c378e66..c9e01a3 100644
--- a/net/irda/irnet/irnet_irda.c
+++ b/net/irda/irnet/irnet_irda.c
@@ -24,56 +24,53 @@
  * so they can read the log...
  */
 static void
-irnet_post_event(irnet_socket *	ap,
-		 irnet_event	event,
-		 __u32		saddr,
-		 __u32		daddr,
-		 char *		name,
-		 __u16		hints)
+irnet_post_event(irnet_socket * ap,
+		 irnet_event event,
+		 __u32 saddr, __u32 daddr, char *name, __u16 hints)
 {
-  int			index;		/* In the log */
-
-  DENTER(CTRL_TRACE, "(ap=0x%p, event=%d, daddr=%08x, name=``%s'')\n",
-	 ap, event, daddr, name);
-
-  /* Protect this section via spinlock.
-   * Note : as we are the only event producer, we only need to exclude
-   * ourself when touching the log, which is nice and easy.
-   */
-  spin_lock_bh(&irnet_events.spinlock);
-
-  /* Copy the event in the log */
-  index = irnet_events.index;
-  irnet_events.log[index].event = event;
-  irnet_events.log[index].daddr = daddr;
-  irnet_events.log[index].saddr = saddr;
-  /* Try to copy IrDA nickname */
-  if(name)
-    strcpy(irnet_events.log[index].name, name);
-  else
-    irnet_events.log[index].name[0] = '\0';
-  /* Copy hints */
-  irnet_events.log[index].hints.word = hints;
-  /* Try to get ppp unit number */
-  if((ap != (irnet_socket *) NULL) && (ap->ppp_open))
-    irnet_events.log[index].unit = ppp_unit_number(&ap->chan);
-  else
-    irnet_events.log[index].unit = -1;
-
-  /* Increment the index
-   * Note that we increment the index only after the event is written,
-   * to make sure that the readers don't get garbage... */
-  irnet_events.index = (index + 1) % IRNET_MAX_EVENTS;
-
-  DEBUG(CTRL_INFO, "New event index is %d\n", irnet_events.index);
-
-  /* Spin lock end */
-  spin_unlock_bh(&irnet_events.spinlock);
-
-  /* Now : wake up everybody waiting for events... */
-  wake_up_interruptible_all(&irnet_events.rwait);
-
-  DEXIT(CTRL_TRACE, "\n");
+	int index;		/* In the log */
+
+	DENTER(CTRL_TRACE, "(ap=0x%p, event=%d, daddr=%08x, name=``%s'')\n",
+	       ap, event, daddr, name);
+
+	/* Protect this section via spinlock.
+	 * Note : as we are the only event producer, we only need to exclude
+	 * ourself when touching the log, which is nice and easy.
+	 */
+	spin_lock_bh(&irnet_events.spinlock);
+
+	/* Copy the event in the log */
+	index = irnet_events.index;
+	irnet_events.log[index].event = event;
+	irnet_events.log[index].daddr = daddr;
+	irnet_events.log[index].saddr = saddr;
+	/* Try to copy IrDA nickname */
+	if (name)
+		strcpy(irnet_events.log[index].name, name);
+	else
+		irnet_events.log[index].name[0] = '\0';
+	/* Copy hints */
+	irnet_events.log[index].hints.word = hints;
+	/* Try to get ppp unit number */
+	if ((ap != (irnet_socket *) NULL) && (ap->ppp_open))
+		irnet_events.log[index].unit = ppp_unit_number(&ap->chan);
+	else
+		irnet_events.log[index].unit = -1;
+
+	/* Increment the index
+	 * Note that we increment the index only after the event is written,
+	 * to make sure that the readers don't get garbage... */
+	irnet_events.index = (index + 1) % IRNET_MAX_EVENTS;
+
+	DEBUG(CTRL_INFO, "New event index is %d\n", irnet_events.index);
+
+	/* Spin lock end */
+	spin_unlock_bh(&irnet_events.spinlock);
+
+	/* Now : wake up everybody waiting for events... */
+	wake_up_interruptible_all(&irnet_events.rwait);
+
+	DEXIT(CTRL_TRACE, "\n");
 }
 
 /************************* IRDA SUBROUTINES *************************/
@@ -95,39 +92,38 @@ irnet_post_event(irnet_socket *	ap,
  *
  * Create a IrTTP instance for us and set all the IrTTP callbacks.
  */
-static inline int
-irnet_open_tsap(irnet_socket *	self)
+static inline int irnet_open_tsap(irnet_socket * self)
 {
-  notify_t	notify;		/* Callback structure */
-
-  DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
-
-  DABORT(self->tsap != NULL, -EBUSY, IRDA_SR_ERROR, "Already busy !\n");
-
-  /* Initialize IrTTP callbacks to be used by the IrDA stack */
-  irda_notify_init(&notify);
-  notify.connect_confirm	= irnet_connect_confirm;
-  notify.connect_indication	= irnet_connect_indication;
-  notify.disconnect_indication	= irnet_disconnect_indication;
-  notify.data_indication	= irnet_data_indication;
-  /*notify.udata_indication	= NULL;*/
-  notify.flow_indication	= irnet_flow_indication;
-  notify.status_indication	= irnet_status_indication;
-  notify.instance		= self;
-  strlcpy(notify.name, IRNET_NOTIFY_NAME, sizeof(notify.name));
-
-  /* Open an IrTTP instance */
-  self->tsap = irttp_open_tsap(LSAP_ANY, DEFAULT_INITIAL_CREDIT,
-			       &notify);
-  DABORT(self->tsap == NULL, -ENOMEM,
-	 IRDA_SR_ERROR, "Unable to allocate TSAP !\n");
-
-  /* Remember which TSAP selector we actually got */
-  self->stsap_sel = self->tsap->stsap_sel;
-
-  DEXIT(IRDA_SR_TRACE, " - tsap=0x%p, sel=0x%X\n",
-	self->tsap, self->stsap_sel);
-  return 0;
+	notify_t notify;	/* Callback structure */
+
+	DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
+
+	DABORT(self->tsap != NULL, -EBUSY, IRDA_SR_ERROR, "Already busy !\n");
+
+	/* Initialize IrTTP callbacks to be used by the IrDA stack */
+	irda_notify_init(&notify);
+	notify.connect_confirm = irnet_connect_confirm;
+	notify.connect_indication = irnet_connect_indication;
+	notify.disconnect_indication = irnet_disconnect_indication;
+	notify.data_indication = irnet_data_indication;
+	/*notify.udata_indication     = NULL; */
+	notify.flow_indication = irnet_flow_indication;
+	notify.status_indication = irnet_status_indication;
+	notify.instance = self;
+	strlcpy(notify.name, IRNET_NOTIFY_NAME, sizeof(notify.name));
+
+	/* Open an IrTTP instance */
+	self->tsap = irttp_open_tsap(LSAP_ANY,
+				     DEFAULT_INITIAL_CREDIT, &notify);
+	DABORT(self->tsap == NULL, -ENOMEM,
+	       IRDA_SR_ERROR, "Unable to allocate TSAP !\n");
+
+	/* Remember which TSAP selector we actually got */
+	self->stsap_sel = self->tsap->stsap_sel;
+
+	DEXIT(IRDA_SR_TRACE, " - tsap=0x%p, sel=0x%X\n",
+	      self->tsap, self->stsap_sel);
+	return 0;
 }
 
 /*------------------------------------------------------------------*/
@@ -145,75 +141,70 @@ irnet_open_tsap(irnet_socket *	self)
  * Return TSAP or -1
  */
 static inline __u8
-irnet_ias_to_tsap(irnet_socket *	self,
-		  int			result,
-		  struct ias_value *	value)
+irnet_ias_to_tsap(irnet_socket * self, int result, struct ias_value *value)
 {
-  __u8	dtsap_sel = 0;		/* TSAP we are looking for */
-
-  DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
-
-  /* By default, no error */
-  self->errno = 0;
-
-  /* Check if request succeeded */
-  switch(result)
-    {
-      /* Standard errors : service not available */
-    case IAS_CLASS_UNKNOWN:
-    case IAS_ATTRIB_UNKNOWN:
-      DEBUG(IRDA_SR_INFO, "IAS object doesn't exist ! (%d)\n", result);
-      self->errno = -EADDRNOTAVAIL;
-      break;
-
-      /* Other errors, most likely IrDA stack failure */
-    default :
-      DEBUG(IRDA_SR_INFO, "IAS query failed ! (%d)\n", result);
-      self->errno = -EHOSTUNREACH;
-      break;
-
-      /* Success : we got what we wanted */
-    case IAS_SUCCESS:
-      break;
-    }
-
-  /* Check what was returned to us */
-  if(value != NULL)
-    {
-      /* What type of argument have we got ? */
-      switch(value->type)
-	{
-	case IAS_INTEGER:
-	  DEBUG(IRDA_SR_INFO, "result=%d\n", value->t.integer);
-	  if(value->t.integer != -1)
-	    /* Get the remote TSAP selector */
-	    dtsap_sel = value->t.integer;
-	  else
-	    self->errno = -EADDRNOTAVAIL;
-	  break;
+	__u8 dtsap_sel = 0;	/* TSAP we are looking for */
+
+	DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
+
+	/* By default, no error */
+	self->errno = 0;
+
+	/* Check if request succeeded */
+	switch (result) {
+		/* Standard errors : service not available */
+	case IAS_CLASS_UNKNOWN:
+	case IAS_ATTRIB_UNKNOWN:
+		DEBUG(IRDA_SR_INFO, "IAS object doesn't exist ! (%d)\n",
+		      result);
+		self->errno = -EADDRNOTAVAIL;
+		break;
+
+		/* Other errors, most likely IrDA stack failure */
 	default:
-	  self->errno = -EADDRNOTAVAIL;
-	  DERROR(IRDA_SR_ERROR, "bad type ! (0x%X)\n", value->type);
-	  break;
+		DEBUG(IRDA_SR_INFO, "IAS query failed ! (%d)\n", result);
+		self->errno = -EHOSTUNREACH;
+		break;
+
+		/* Success : we got what we wanted */
+	case IAS_SUCCESS:
+		break;
 	}
 
-      /* Cleanup */
-      irias_delete_value(value);
-    }
-  else	/* value == NULL */
-    {
-      /* Nothing returned to us - usually result != SUCCESS */
-      if(!(self->errno))
-	{
-	  DERROR(IRDA_SR_ERROR,
-		 "IrDA bug : result == SUCCESS && value == NULL\n");
-	  self->errno = -EHOSTUNREACH;
+	/* Check what was returned to us */
+	if (value != NULL) {
+		/* What type of argument have we got ? */
+		switch (value->type) {
+		case IAS_INTEGER:
+			DEBUG(IRDA_SR_INFO, "result=%d\n", value->t.integer);
+			if (value->t.integer != -1)
+				/* Get the remote TSAP selector */
+				dtsap_sel = value->t.integer;
+			else
+				self->errno = -EADDRNOTAVAIL;
+			break;
+		default:
+			self->errno = -EADDRNOTAVAIL;
+			DERROR(IRDA_SR_ERROR, "bad type ! (0x%X)\n",
+			       value->type);
+			break;
+		}
+
+		/* Cleanup */
+		irias_delete_value(value);
+	} else {		/* value == NULL */
+
+		/* Nothing returned to us - usually result != SUCCESS */
+		if (!(self->errno)) {
+			DERROR(IRDA_SR_ERROR,
+			       "IrDA bug : result == SUCCESS && value == NULL\n");
+			self->errno = -EHOSTUNREACH;
+		}
 	}
-    }
-  DEXIT(IRDA_SR_TRACE, "\n");
+	DEXIT(IRDA_SR_TRACE, "\n");
 
-  /* Return the TSAP */
-  return(dtsap_sel);
+	/* Return the TSAP */
+	return (dtsap_sel);
 }
 
 /*------------------------------------------------------------------*/
@@ -228,32 +219,34 @@ irnet_ias_to_tsap(irnet_socket *	self,
  * Note that in some case, the query fail even before we go to sleep,
  * creating some races...
  */
-static inline int
-irnet_find_lsap_sel(irnet_socket *	self)
+static inline int irnet_find_lsap_sel(irnet_socket * self)
 {
-  DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
+	DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
 
-  /* This should not happen */
-  DABORT(self->iriap, -EBUSY, IRDA_SR_ERROR, "busy with a previous query.\n");
+	/* This should not happen */
+	DABORT(self->iriap, -EBUSY, IRDA_SR_ERROR,
+	       "busy with a previous query.\n");
 
-  /* Create an IAP instance, will be closed in irnet_getvalue_confirm() */
-  self->iriap = iriap_open(LSAP_ANY, IAS_CLIENT, self,
-			   irnet_getvalue_confirm);
+	/*
+	 * Create an IAP instance, will be closed in irnet_getvalue_confirm()
+	 */
+	self->iriap = iriap_open(LSAP_ANY, IAS_CLIENT, self,
+				 irnet_getvalue_confirm);
 
-  /* Treat unexpected signals as disconnect */
-  self->errno = -EHOSTUNREACH;
+	/* Treat unexpected signals as disconnect */
+	self->errno = -EHOSTUNREACH;
 
-  /* Query remote LM-IAS */
-  iriap_getvaluebyclass_request(self->iriap, self->rsaddr, self->daddr,
-				IRNET_SERVICE_NAME, IRNET_IAS_VALUE);
+	/* Query remote LM-IAS */
+	iriap_getvaluebyclass_request(self->iriap, self->rsaddr, self->daddr,
+				      IRNET_SERVICE_NAME, IRNET_IAS_VALUE);
 
-  /* The above request is non-blocking.
-   * After a while, IrDA will call us back in irnet_getvalue_confirm()
-   * We will then call irnet_ias_to_tsap() and finish the
-   * connection procedure */
+	/* The above request is non-blocking.
+	 * After a while, IrDA will call us back in irnet_getvalue_confirm()
+	 * We will then call irnet_ias_to_tsap() and finish the
+	 * connection procedure */
 
-  DEXIT(IRDA_SR_TRACE, "\n");
-  return 0;
+	DEXIT(IRDA_SR_TRACE, "\n");
+	return 0;
 }
 
 /*------------------------------------------------------------------*/
@@ -263,40 +256,37 @@ irnet_find_lsap_sel(irnet_socket *	self)
  *    Initialise the TTP socket and initiate TTP connection
  *
  */
-static inline int
-irnet_connect_tsap(irnet_socket *	self)
+static inline int irnet_connect_tsap(irnet_socket * self)
 {
-  int		err;
-
-  DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
-
-  /* Open a local TSAP (an IrTTP instance) */
-  err = irnet_open_tsap(self);
-  if(err != 0)
-    {
-      clear_bit(0, &self->ttp_connect);
-      DERROR(IRDA_SR_ERROR, "connect aborted!\n");
-      return(err);
-    }
-
-  /* Connect to remote device */
-  err = irttp_connect_request(self->tsap, self->dtsap_sel,
-			      self->rsaddr, self->daddr, NULL,
-			      self->max_sdu_size_rx, NULL);
-  if(err != 0)
-    {
-      clear_bit(0, &self->ttp_connect);
-      DERROR(IRDA_SR_ERROR, "connect aborted!\n");
-      return(err);
-    }
-
-  /* The above call is non-blocking.
-   * After a while, the IrDA stack will either call us back in
-   * irnet_connect_confirm() or irnet_disconnect_indication()
-   * See you there ;-) */
-
-  DEXIT(IRDA_SR_TRACE, "\n");
-  return(err);
+	int err;
+
+	DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
+
+	/* Open a local TSAP (an IrTTP instance) */
+	err = irnet_open_tsap(self);
+	if (err != 0) {
+		clear_bit(0, &self->ttp_connect);
+		DERROR(IRDA_SR_ERROR, "connect aborted!\n");
+		return (err);
+	}
+
+	/* Connect to remote device */
+	err = irttp_connect_request(self->tsap, self->dtsap_sel,
+				    self->rsaddr, self->daddr, NULL,
+				    self->max_sdu_size_rx, NULL);
+	if (err != 0) {
+		clear_bit(0, &self->ttp_connect);
+		DERROR(IRDA_SR_ERROR, "connect aborted!\n");
+		return (err);
+	}
+
+	/* The above call is non-blocking.
+	 * After a while, the IrDA stack will either call us back in
+	 * irnet_connect_confirm() or irnet_disconnect_indication()
+	 * See you there ;-) */
+
+	DEXIT(IRDA_SR_TRACE, "\n");
+	return (err);
 }
 
 /*------------------------------------------------------------------*/
@@ -307,40 +297,42 @@ irnet_connect_tsap(irnet_socket *	self)
  *
  * Used in the TSAP discovery procedure.
  */
-static inline int
-irnet_discover_next_daddr(irnet_socket *	self)
+static inline int irnet_discover_next_daddr(irnet_socket * self)
 {
-  /* Close the last instance of IrIAP, and open a new one.
-   * We can't reuse the IrIAP instance in the IrIAP callback */
-  if(self->iriap)
-    {
-      iriap_close(self->iriap);
-      self->iriap = NULL;
-    }
-  /* Create a new IAP instance */
-  self->iriap = iriap_open(LSAP_ANY, IAS_CLIENT, self,
-			   irnet_discovervalue_confirm);
-  if(self->iriap == NULL)
-    return -ENOMEM;
-
-  /* Next discovery - before the call to avoid races */
-  self->disco_index++;
-
-  /* Check if we have one more address to try */
-  if(self->disco_index < self->disco_number)
-    {
-      /* Query remote LM-IAS */
-      iriap_getvaluebyclass_request(self->iriap,
-				    self->discoveries[self->disco_index].saddr,
-				    self->discoveries[self->disco_index].daddr,
-				    IRNET_SERVICE_NAME, IRNET_IAS_VALUE);
-      /* The above request is non-blocking.
-       * After a while, IrDA will call us back in irnet_discovervalue_confirm()
-       * We will then call irnet_ias_to_tsap() and come back here again... */
-      return(0);
-    }
-  else
-    return(1);
+	/* Close the last instance of IrIAP, and open a new one.
+	 * We can't reuse the IrIAP instance in the IrIAP callback */
+	if (self->iriap) {
+		iriap_close(self->iriap);
+		self->iriap = NULL;
+	}
+	/* Create a new IAP instance */
+	self->iriap = iriap_open(LSAP_ANY, IAS_CLIENT, self,
+				 irnet_discovervalue_confirm);
+	if (self->iriap == NULL)
+		return -ENOMEM;
+
+	/* Next discovery - before the call to avoid races */
+	self->disco_index++;
+
+	/* Check if we have one more address to try */
+	if (self->disco_index < self->disco_number) {
+		/* Query remote LM-IAS */
+		iriap_getvaluebyclass_request(self->iriap,
+					      self->discoveries[self->
+								disco_index].
+					      saddr,
+					      self->discoveries[self->
+								disco_index].
+					      daddr, IRNET_SERVICE_NAME,
+					      IRNET_IAS_VALUE);
+		/* The above request is non-blocking.
+		 * After a while, IrDA will call us back in
+		 * irnet_discovervalue_confirm(). We will
+		 * then call irnet_ias_to_tsap() and come back here again...
+		 */
+		return (0);
+	} else
+		return (1);
 }
 
 /*------------------------------------------------------------------*/
@@ -366,52 +358,50 @@ irnet_discover_next_daddr(irnet_socket *	self)
  * last LSAP is closed. Moreover, we would need to wait the LAP
  * disconnection...
  */
-static inline int
-irnet_discover_daddr_and_lsap_sel(irnet_socket *	self)
+static inline int irnet_discover_daddr_and_lsap_sel(irnet_socket * self)
 {
-  int	ret;
+	int ret;
 
-  DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
+	DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
 
-  /* Ask lmp for the current discovery log */
-  self->discoveries = irlmp_get_discoveries(&self->disco_number, self->mask,
-					    DISCOVERY_DEFAULT_SLOTS);
+	/* Ask lmp for the current discovery log */
+	self->discoveries =
+	    irlmp_get_discoveries(&self->disco_number, self->mask,
+				  DISCOVERY_DEFAULT_SLOTS);
 
-  /* Check if the we got some results */
-  if(self->discoveries == NULL)
-    {
-      self->disco_number = -1;
-      clear_bit(0, &self->ttp_connect);
-      DRETURN(-ENETUNREACH, IRDA_SR_INFO, "No Cachelog...\n");
-    }
-  DEBUG(IRDA_SR_INFO, "Got the log (0x%p), size is %d\n",
-	self->discoveries, self->disco_number);
-
-  /* Start with the first discovery */
-  self->disco_index = -1;
-  self->daddr = DEV_ADDR_ANY;
-
-  /* This will fail if the log is empty - this is non-blocking */
-  ret = irnet_discover_next_daddr(self);
-  if(ret)
-    {
-      /* Close IAP */
-      if(self->iriap)
-	iriap_close(self->iriap);
-      self->iriap = NULL;
-
-      /* Cleanup our copy of the discovery log */
-      kfree(self->discoveries);
-      self->discoveries = NULL;
-
-      clear_bit(0, &self->ttp_connect);
-      DRETURN(-ENETUNREACH, IRDA_SR_INFO, "Cachelog empty...\n");
-    }
+	/* Check if the we got some results */
+	if (self->discoveries == NULL) {
+		self->disco_number = -1;
+		clear_bit(0, &self->ttp_connect);
+		DRETURN(-ENETUNREACH, IRDA_SR_INFO, "No Cachelog...\n");
+	}
+	DEBUG(IRDA_SR_INFO, "Got the log (0x%p), size is %d\n",
+	      self->discoveries, self->disco_number);
+
+	/* Start with the first discovery */
+	self->disco_index = -1;
+	self->daddr = DEV_ADDR_ANY;
+
+	/* This will fail if the log is empty - this is non-blocking */
+	ret = irnet_discover_next_daddr(self);
+	if (ret) {
+		/* Close IAP */
+		if (self->iriap)
+			iriap_close(self->iriap);
+		self->iriap = NULL;
+
+		/* Cleanup our copy of the discovery log */
+		kfree(self->discoveries);
+		self->discoveries = NULL;
+
+		clear_bit(0, &self->ttp_connect);
+		DRETURN(-ENETUNREACH, IRDA_SR_INFO, "Cachelog empty...\n");
+	}
 
-  /* Follow me in irnet_discovervalue_confirm() */
+	/* Follow me in irnet_discovervalue_confirm() */
 
-  DEXIT(IRDA_SR_TRACE, "\n");
-  return(0);
+	DEXIT(IRDA_SR_TRACE, "\n");
+	return (0);
 }
 
 /*------------------------------------------------------------------*/
@@ -422,48 +412,47 @@ irnet_discover_daddr_and_lsap_sel(irnet_socket *	self)
  *
  * It basically look into the discovery log until there is a match.
  */
-static inline int
-irnet_dname_to_daddr(irnet_socket *	self)
+static inline int irnet_dname_to_daddr(irnet_socket * self)
 {
-  struct irda_device_info *discoveries;	/* Copy of the discovery log */
-  int	number;			/* Number of nodes in the log */
-  int	i;
-
-  DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
-
-  /* Ask lmp for the current discovery log */
-  discoveries = irlmp_get_discoveries(&number, 0xffff,
-				      DISCOVERY_DEFAULT_SLOTS);
-  /* Check if the we got some results */
-  if(discoveries == NULL)
-    DRETURN(-ENETUNREACH, IRDA_SR_INFO, "Cachelog empty...\n");
-
-  /*
-   * Now, check all discovered devices (if any), and connect
-   * client only about the services that the client is
-   * interested in...
-   */
-  for(i = 0; i < number; i++)
-    {
-      /* Does the name match ? */
-      if(!strncmp(discoveries[i].info, self->rname, NICKNAME_MAX_LEN))
-	{
-	  /* Yes !!! Get it.. */
-	  self->daddr = discoveries[i].daddr;
-	  DEBUG(IRDA_SR_INFO, "discovered device ``%s'' at address 0x%08x.\n",
-		self->rname, self->daddr);
-	  kfree(discoveries);
-	  DEXIT(IRDA_SR_TRACE, "\n");
-	  return 0;
+	struct irda_device_info *discoveries;	/* Copy of the discovery log */
+	int number;		/* Number of nodes in the log */
+	int i;
+
+	DENTER(IRDA_SR_TRACE, "(self=0x%p)\n", self);
+
+	/* Ask lmp for the current discovery log */
+	discoveries = irlmp_get_discoveries(&number, 0xffff,
+					    DISCOVERY_DEFAULT_SLOTS);
+	/* Check if the we got some results */
+	if (discoveries == NULL)
+		DRETURN(-ENETUNREACH, IRDA_SR_INFO, "Cachelog empty...\n");
+
+	/*
+	 * Now, check all discovered devices (if any), and connect
+	 * client only about the services that the client is
+	 * interested in...
+	 */
+	for (i = 0; i < number; i++) {
+		/* Does the name match ? */
+		if (!strncmp
+		    (discoveries[i].info, self->rname, NICKNAME_MAX_LEN)) {
+			/* Yes !!! Get it.. */
+			self->daddr = discoveries[i].daddr;
+			DEBUG(IRDA_SR_INFO,
+			      "discovered device ``%s'' at address 0x%08x.\n",
+			      self->rname, self->daddr);
+			kfree(discoveries);
+			DEXIT(IRDA_SR_TRACE, "\n");
+			return 0;
+		}
 	}
-    }
-  /* No luck ! */
-  DEBUG(IRDA_SR_INFO, "cannot discover device ``%s'' !!!\n", self->rname);
-  kfree(discoveries);
-  return(-EADDRNOTAVAIL);
+	/* No luck ! */
+	DEBUG(IRDA_SR_INFO, "cannot discover device ``%s'' !!!\n",
+	      self->rname);
+	kfree(discoveries);
+	return (-EADDRNOTAVAIL);
 }
 
-
 /************************* SOCKET ROUTINES *************************/
 /*
  * This are the main operations on IrNET sockets, basically to create
@@ -474,33 +463,32 @@ irnet_dname_to_daddr(irnet_socket *	self)
 /*
  * Create a IrNET instance : just initialise some parameters...
  */
-int
-irda_irnet_create(irnet_socket *	self)
+int irda_irnet_create(irnet_socket * self)
 {
-  DENTER(IRDA_SOCK_TRACE, "(self=0x%p)\n", self);
+	DENTER(IRDA_SOCK_TRACE, "(self=0x%p)\n", self);
 
-  self->magic = IRNET_MAGIC;	/* Paranoia */
+	self->magic = IRNET_MAGIC;	/* Paranoia */
 
-  self->ttp_open = 0;		/* Prevent higher layer from accessing IrTTP */
-  self->ttp_connect = 0;	/* Not connecting yet */
-  self->rname[0] = '\0';	/* May be set via control channel */
-  self->rdaddr = DEV_ADDR_ANY;	/* May be set via control channel */
-  self->rsaddr = DEV_ADDR_ANY;	/* May be set via control channel */
-  self->daddr = DEV_ADDR_ANY;	/* Until we get connected */
-  self->saddr = DEV_ADDR_ANY;	/* Until we get connected */
-  self->max_sdu_size_rx = TTP_SAR_UNBOUND;
+	self->ttp_open = 0;	/* Prevent higher layer from accessing IrTTP */
+	self->ttp_connect = 0;	/* Not connecting yet */
+	self->rname[0] = '\0';	/* May be set via control channel */
+	self->rdaddr = DEV_ADDR_ANY;	/* May be set via control channel */
+	self->rsaddr = DEV_ADDR_ANY;	/* May be set via control channel */
+	self->daddr = DEV_ADDR_ANY;	/* Until we get connected */
+	self->saddr = DEV_ADDR_ANY;	/* Until we get connected */
+	self->max_sdu_size_rx = TTP_SAR_UNBOUND;
 
-  /* Register as a client with IrLMP */
-  self->ckey = irlmp_register_client(0, NULL, NULL, NULL);
+	/* Register as a client with IrLMP */
+	self->ckey = irlmp_register_client(0, NULL, NULL, NULL);
 #ifdef DISCOVERY_NOMASK
-  self->mask = 0xffff;		/* For W2k compatibility */
-#else /* DISCOVERY_NOMASK */
-  self->mask = irlmp_service_to_hint(S_LAN);
-#endif /* DISCOVERY_NOMASK */
-  self->tx_flow = FLOW_START;	/* Flow control from IrTTP */
-
-  DEXIT(IRDA_SOCK_TRACE, "\n");
-  return(0);
+	self->mask = 0xffff;	/* For W2k compatibility */
+#else				/* DISCOVERY_NOMASK */
+	self->mask = irlmp_service_to_hint(S_LAN);
+#endif				/* DISCOVERY_NOMASK */
+	self->tx_flow = FLOW_START;	/* Flow control from IrTTP */
+
+	DEXIT(IRDA_SOCK_TRACE, "\n");
+	return (0);
 }
 
 /*------------------------------------------------------------------*/
@@ -516,65 +504,69 @@ irda_irnet_create(irnet_socket *	self)
  * The downside is that following what's happening in there is tricky
  * because it involve various functions all over the place...
  */
-int
-irda_irnet_connect(irnet_socket *	self)
+int irda_irnet_connect(irnet_socket * self)
 {
-  int		err;
-
-  DENTER(IRDA_SOCK_TRACE, "(self=0x%p)\n", self);
-
-  /* Check if we are already trying to connect.
-   * Because irda_irnet_connect() can be called directly by pppd plus
-   * packet retries in ppp_generic and connect may take time, plus we may
-   * race with irnet_connect_indication(), we need to be careful there... */
-  if(test_and_set_bit(0, &self->ttp_connect))
-    DRETURN(-EBUSY, IRDA_SOCK_INFO, "Already connecting...\n");
-  if((self->iriap != NULL) || (self->tsap != NULL))
-    DERROR(IRDA_SOCK_ERROR, "Socket not cleaned up...\n");
-
-  /* Insert ourselves in the hashbin so that the IrNET server can find us.
-   * Notes : 4th arg is string of 32 char max and must be null terminated
-   *	     When 4th arg is used (string), 3rd arg isn't (int)
-   *	     Can't re-insert (MUST remove first) so check for that... */
-  if((irnet_server.running) && (self->q.q_next == NULL))
-    {
-      spin_lock_bh(&irnet_server.spinlock);
-      hashbin_insert(irnet_server.list, (irda_queue_t *) self, 0, self->rname);
-      spin_unlock_bh(&irnet_server.spinlock);
-      DEBUG(IRDA_SOCK_INFO, "Inserted ``%s'' in hashbin...\n", self->rname);
-    }
-
-  /* If we don't have anything (no address, no name) */
-  if((self->rdaddr == DEV_ADDR_ANY) && (self->rname[0] == '\0'))
-    {
-      /* Try to find a suitable address */
-      if((err = irnet_discover_daddr_and_lsap_sel(self)) != 0)
-	DRETURN(err, IRDA_SOCK_INFO, "auto-connect failed!\n");
-      /* In most cases, the call above is non-blocking */
-    }
-  else
-    {
-      /* If we have only the name (no address), try to get an address */
-      if(self->rdaddr == DEV_ADDR_ANY)
-	{
-	  if((err = irnet_dname_to_daddr(self)) != 0)
-	    DRETURN(err, IRDA_SOCK_INFO, "name connect failed!\n");
+	int err;
+
+	DENTER(IRDA_SOCK_TRACE, "(self=0x%p)\n", self);
+
+	/*
+	 * Check if we are already trying to connect.
+	 * Because irda_irnet_connect() can be called directly by pppd plus
+	 * packet retries in ppp_generic and connect may take time, plus we may
+	 * race with irnet_connect_indication(), we need to be careful
+	 * there...
+	 */
+	if (test_and_set_bit(0, &self->ttp_connect))
+		DRETURN(-EBUSY, IRDA_SOCK_INFO, "Already connecting...\n");
+	if ((self->iriap != NULL) || (self->tsap != NULL))
+		DERROR(IRDA_SOCK_ERROR, "Socket not cleaned up...\n");
+
+	/*
+	 * Insert ourselves in the hashbin so that the IrNET server
+	 * can find us.
+	 * Notes : 4th arg is string of 32 char max and must be null terminated
+	 *         When 4th arg is used (string), 3rd arg isn't (int)
+	 *         Can't re-insert (MUST remove first) so check for that...
+	 */
+	if ((irnet_server.running) && (self->q.q_next == NULL)) {
+		spin_lock_bh(&irnet_server.spinlock);
+		hashbin_insert(irnet_server.list, (irda_queue_t *) self, 0,
+			       self->rname);
+		spin_unlock_bh(&irnet_server.spinlock);
+		DEBUG(IRDA_SOCK_INFO, "Inserted ``%s'' in hashbin...\n",
+		      self->rname);
+	}
+
+	/* If we don't have anything (no address, no name) */
+	if ((self->rdaddr == DEV_ADDR_ANY) && (self->rname[0] == '\0')) {
+		/* Try to find a suitable address */
+		if ((err = irnet_discover_daddr_and_lsap_sel(self)) != 0)
+			DRETURN(err, IRDA_SOCK_INFO, "auto-connect failed!\n");
+		/* In most cases, the call above is non-blocking */
+	} else {
+		/* If we have only the name (no address),
+		 * try to get an address
+		 */
+		if (self->rdaddr == DEV_ADDR_ANY) {
+			if ((err = irnet_dname_to_daddr(self)) != 0)
+				DRETURN(err, IRDA_SOCK_INFO,
+					"name connect failed!\n");
+		} else
+			/* Use the requested destination address */
+			self->daddr = self->rdaddr;
+
+		/* Query remote LM-IAS to find LSAP selector */
+		irnet_find_lsap_sel(self);
+		/* The above call is non blocking */
 	}
-      else
-	/* Use the requested destination address */
-	self->daddr = self->rdaddr;
-
-      /* Query remote LM-IAS to find LSAP selector */
-      irnet_find_lsap_sel(self);
-      /* The above call is non blocking */
-    }
-
-  /* At this point, we are waiting for the IrDA stack to call us back,
-   * or we have already failed.
-   * We will finish the connection procedure in irnet_connect_tsap().
-   */
-  DEXIT(IRDA_SOCK_TRACE, "\n");
-  return(0);
+
+	/* At this point, we are waiting for the IrDA stack to call us back,
+	 * or we have already failed.
+	 * We will finish the connection procedure in irnet_connect_tsap().
+	 */
+	DEXIT(IRDA_SOCK_TRACE, "\n");
+	return (0);
 }
 
 /*------------------------------------------------------------------*/
@@ -585,75 +577,79 @@ irda_irnet_connect(irnet_socket *	self)
  *
  * Note : this need to be called from a process context.
  */
-void
-irda_irnet_destroy(irnet_socket *	self)
+void irda_irnet_destroy(irnet_socket * self)
 {
-  DENTER(IRDA_SOCK_TRACE, "(self=0x%p)\n", self);
-  if(self == NULL)
-    return;
-
-  /* Remove ourselves from hashbin (if we are queued in hashbin)
-   * Note : `irnet_server.running' protect us from calls in hashbin_delete() */
-  if((irnet_server.running) && (self->q.q_next != NULL))
-    {
-      struct irnet_socket *	entry;
-      DEBUG(IRDA_SOCK_INFO, "Removing from hash..\n");
-      spin_lock_bh(&irnet_server.spinlock);
-      entry = hashbin_remove_this(irnet_server.list, (irda_queue_t *) self);
-      self->q.q_next = NULL;
-      spin_unlock_bh(&irnet_server.spinlock);
-      DASSERT(entry == self, , IRDA_SOCK_ERROR, "Can't remove from hash.\n");
-    }
-
-  /* If we were connected, post a message */
-  if(test_bit(0, &self->ttp_open))
-    {
-      /* Note : as the disconnect comes from ppp_generic, the unit number
-       * doesn't exist anymore when we post the event, so we need to pass
-       * NULL as the first arg... */
-      irnet_post_event(NULL, IRNET_DISCONNECT_TO,
-		       self->saddr, self->daddr, self->rname, 0);
-    }
-
-  /* Prevent various IrDA callbacks from messing up things
-   * Need to be first */
-  clear_bit(0, &self->ttp_connect);
-
-  /* Prevent higher layer from accessing IrTTP */
-  clear_bit(0, &self->ttp_open);
-
-  /* Unregister with IrLMP */
-  irlmp_unregister_client(self->ckey);
-
-  /* Unregister with LM-IAS */
-  if(self->iriap)
-    {
-      iriap_close(self->iriap);
-      self->iriap = NULL;
-    }
-
-  /* Cleanup eventual discoveries from connection attempt or control channel */
-  if(self->discoveries != NULL)
-    {
-      /* Cleanup our copy of the discovery log */
-      kfree(self->discoveries);
-      self->discoveries = NULL;
-    }
-
-  /* Close our IrTTP connection */
-  if(self->tsap)
-    {
-      DEBUG(IRDA_SOCK_INFO, "Closing our TTP connection.\n");
-      irttp_disconnect_request(self->tsap, NULL, P_NORMAL);
-      irttp_close_tsap(self->tsap);
-      self->tsap = NULL;
-    }
-  self->stsap_sel = 0;
-
-  DEXIT(IRDA_SOCK_TRACE, "\n");
-  return;
-}
+	DENTER(IRDA_SOCK_TRACE, "(self=0x%p)\n", self);
+	if (self == NULL)
+		return;
+
+	/*
+	 * Remove ourselves from hashbin (if we are queued in hashbin)
+	 * Note : `irnet_server.running' protect us from calls in
+	 * hashbin_delete()
+	 */
+	if ((irnet_server.running) && (self->q.q_next != NULL)) {
+		struct irnet_socket *entry;
+		DEBUG(IRDA_SOCK_INFO, "Removing from hash..\n");
+		spin_lock_bh(&irnet_server.spinlock);
+		entry =
+		    hashbin_remove_this(irnet_server.list,
+					(irda_queue_t *) self);
+		self->q.q_next = NULL;
+		spin_unlock_bh(&irnet_server.spinlock);
+		DASSERT(entry == self,, IRDA_SOCK_ERROR,
+			"Can't remove from hash.\n");
+	}
+
+	/* If we were connected, post a message */
+	if (test_bit(0, &self->ttp_open)) {
+		/*
+		 * Note : as the disconnect comes from ppp_generic,
+		 * the unit number doesn't exist anymore when we post
+		 * the event, so we need to pas NULL as the first arg...
+		 */
+		irnet_post_event(NULL, IRNET_DISCONNECT_TO,
+				 self->saddr, self->daddr, self->rname, 0);
+	}
+
+	/* Prevent various IrDA callbacks from messing up things
+	 * Need to be first */
+	clear_bit(0, &self->ttp_connect);
+
+	/* Prevent higher layer from accessing IrTTP */
+	clear_bit(0, &self->ttp_open);
 
+	/* Unregister with IrLMP */
+	irlmp_unregister_client(self->ckey);
+
+	/* Unregister with LM-IAS */
+	if (self->iriap) {
+		iriap_close(self->iriap);
+		self->iriap = NULL;
+	}
+
+	/*
+	 * Cleanup eventual discoveries from connection attempt or
+	 * control channel.
+	 */
+	if (self->discoveries != NULL) {
+		/* Cleanup our copy of the discovery log */
+		kfree(self->discoveries);
+		self->discoveries = NULL;
+	}
+
+	/* Close our IrTTP connection */
+	if (self->tsap) {
+		DEBUG(IRDA_SOCK_INFO, "Closing our TTP connection.\n");
+		irttp_disconnect_request(self->tsap, NULL, P_NORMAL);
+		irttp_close_tsap(self->tsap);
+		self->tsap = NULL;
+	}
+	self->stsap_sel = 0;
+
+	DEXIT(IRDA_SOCK_TRACE, "\n");
+	return;
+}
 
 /************************** SERVER SOCKET **************************/
 /*
@@ -672,42 +668,42 @@ irda_irnet_destroy(irnet_socket *	self)
  *
  * It basically look into the discovery log until there is a match.
  */
-static inline int
-irnet_daddr_to_dname(irnet_socket *	self)
+static inline int irnet_daddr_to_dname(irnet_socket * self)
 {
-  struct irda_device_info *discoveries;	/* Copy of the discovery log */
-  int	number;			/* Number of nodes in the log */
-  int	i;
-
-  DENTER(IRDA_SERV_TRACE, "(self=0x%p)\n", self);
-
-  /* Ask lmp for the current discovery log */
-  discoveries = irlmp_get_discoveries(&number, 0xffff,
-				      DISCOVERY_DEFAULT_SLOTS);
-  /* Check if the we got some results */
-  if (discoveries == NULL)
-    DRETURN(-ENETUNREACH, IRDA_SERV_INFO, "Cachelog empty...\n");
-
-  /* Now, check all discovered devices (if any) */
-  for(i = 0; i < number; i++)
-    {
-      /* Does the name match ? */
-      if(discoveries[i].daddr == self->daddr)
-	{
-	  /* Yes !!! Get it.. */
-	  strlcpy(self->rname, discoveries[i].info, sizeof(self->rname));
-	  self->rname[sizeof(self->rname) - 1] = '\0';
-	  DEBUG(IRDA_SERV_INFO, "Device 0x%08x is in fact ``%s''.\n",
-		self->daddr, self->rname);
-	  kfree(discoveries);
-	  DEXIT(IRDA_SERV_TRACE, "\n");
-	  return 0;
+	struct irda_device_info *discoveries;	/* Copy of the discovery log */
+	int number;		/* Number of nodes in the log */
+	int i;
+
+	DENTER(IRDA_SERV_TRACE, "(self=0x%p)\n", self);
+
+	/* Ask lmp for the current discovery log */
+	discoveries = irlmp_get_discoveries(&number, 0xffff,
+					    DISCOVERY_DEFAULT_SLOTS);
+	/* Check if the we got some results */
+	if (discoveries == NULL)
+		DRETURN(-ENETUNREACH, IRDA_SERV_INFO, "Cachelog empty...\n");
+
+	/* Now, check all discovered devices (if any) */
+	for (i = 0; i < number; i++) {
+		/* Does the name match ? */
+		if (discoveries[i].daddr == self->daddr) {
+			/* Yes !!! Get it.. */
+			strlcpy(self->rname, discoveries[i].info,
+				sizeof(self->rname));
+			self->rname[sizeof(self->rname) - 1] = '\0';
+			DEBUG(IRDA_SERV_INFO,
+			      "Device 0x%08x is in fact ``%s''.\n",
+			      self->daddr, self->rname);
+			kfree(discoveries);
+			DEXIT(IRDA_SERV_TRACE, "\n");
+			return 0;
+		}
 	}
-    }
-  /* No luck ! */
-  DEXIT(IRDA_SERV_INFO, ": cannot discover device 0x%08x !!!\n", self->daddr);
-  kfree(discoveries);
-  return(-EADDRNOTAVAIL);
+	/* No luck ! */
+	DEXIT(IRDA_SERV_INFO, ": cannot discover device 0x%08x !!!\n",
+	      self->daddr);
+	kfree(discoveries);
+	return (-EADDRNOTAVAIL);
 }
 
 /*------------------------------------------------------------------*/
@@ -719,80 +715,85 @@ irnet_daddr_to_dname(irnet_socket *	self)
  * Look into the list of IrNET sockets and finds one with the right
  * properties...
  */
-static inline irnet_socket *
-irnet_find_socket(irnet_socket *	self)
+static inline irnet_socket *irnet_find_socket(irnet_socket * self)
 {
-  irnet_socket *	new = (irnet_socket *) NULL;
-  int			err;
-
-  DENTER(IRDA_SERV_TRACE, "(self=0x%p)\n", self);
-
-  /* Get the addresses of the requester */
-  self->daddr = irttp_get_daddr(self->tsap);
-  self->saddr = irttp_get_saddr(self->tsap);
-
-  /* Try to get the IrDA nickname of the requester */
-  err = irnet_daddr_to_dname(self);
-
-  /* Protect access to the instance list */
-  spin_lock_bh(&irnet_server.spinlock);
-
-  /* So now, try to get an socket having specifically
-   * requested that nickname */
-  if(err == 0)
-    {
-      new = (irnet_socket *) hashbin_find(irnet_server.list,
-					  0, self->rname);
-      if(new)
-	DEBUG(IRDA_SERV_INFO, "Socket 0x%p matches rname ``%s''.\n",
-	      new, new->rname);
-    }
-
-  /* If no name matches, try to find an socket by the destination address */
-  /* It can be either the requested destination address (set via the
-   * control channel), or the current destination address if the
-   * socket is in the middle of a connection request */
-  if(new == (irnet_socket *) NULL)
-    {
-      new = (irnet_socket *) hashbin_get_first(irnet_server.list);
-      while(new !=(irnet_socket *) NULL)
-	{
-	  /* Does it have the same address ? */
-	  if((new->rdaddr == self->daddr) || (new->daddr == self->daddr))
-	    {
-	      /* Yes !!! Get it.. */
-	      DEBUG(IRDA_SERV_INFO, "Socket 0x%p matches daddr %#08x.\n",
-		    new, self->daddr);
-	      break;
-	    }
-	  new = (irnet_socket *) hashbin_get_next(irnet_server.list);
+	irnet_socket *new = (irnet_socket *) NULL;
+	int err;
+
+	DENTER(IRDA_SERV_TRACE, "(self=0x%p)\n", self);
+
+	/* Get the addresses of the requester */
+	self->daddr = irttp_get_daddr(self->tsap);
+	self->saddr = irttp_get_saddr(self->tsap);
+
+	/* Try to get the IrDA nickname of the requester */
+	err = irnet_daddr_to_dname(self);
+
+	/* Protect access to the instance list */
+	spin_lock_bh(&irnet_server.spinlock);
+
+	/* So now, try to get an socket having specifically
+	 * requested that nickname */
+	if (err == 0) {
+		new = (irnet_socket *) hashbin_find(irnet_server.list,
+						    0, self->rname);
+		if (new)
+			DEBUG(IRDA_SERV_INFO,
+			      "Socket 0x%p matches rname ``%s''.\n", new,
+			      new->rname);
 	}
-    }
-
-  /* If we don't have any socket, get the first unconnected socket */
-  if(new == (irnet_socket *) NULL)
-    {
-      new = (irnet_socket *) hashbin_get_first(irnet_server.list);
-      while(new !=(irnet_socket *) NULL)
-	{
-	  /* Is it available ? */
-	  if(!(test_bit(0, &new->ttp_open)) && (new->rdaddr == DEV_ADDR_ANY) &&
-	     (new->rname[0] == '\0') && (new->ppp_open))
-	    {
-	      /* Yes !!! Get it.. */
-	      DEBUG(IRDA_SERV_INFO, "Socket 0x%p is free.\n",
-		    new);
-	      break;
-	    }
-	  new = (irnet_socket *) hashbin_get_next(irnet_server.list);
+
+	/*
+	 * If no name matches, try to find an socket by the destination
+	 * address
+	 */
+	/*
+	 * It can be either the requested destination address (set via the
+	 * control channel), or the current destination address if the
+	 * socket is in the middle of a connection request
+	 */
+	if (new == (irnet_socket *) NULL) {
+		new = (irnet_socket *) hashbin_get_first(irnet_server.list);
+		while (new != (irnet_socket *) NULL) {
+			/* Does it have the same address ? */
+			if ((new->rdaddr == self->daddr)
+			    || (new->daddr == self->daddr)) {
+				/* Yes !!! Get it.. */
+				DEBUG(IRDA_SERV_INFO,
+				      "Socket 0x%p matches daddr %#08x.\n",
+				      new, self->daddr);
+				break;
+			}
+			new =
+			    (irnet_socket *) hashbin_get_next(irnet_server.
+							      list);
+		}
+	}
+
+	/* If we don't have any socket, get the first unconnected socket */
+	if (new == (irnet_socket *) NULL) {
+		new = (irnet_socket *) hashbin_get_first(irnet_server.list);
+		while (new != (irnet_socket *) NULL) {
+			/* Is it available ? */
+			if (!(test_bit(0, &new->ttp_open))
+			    && (new->rdaddr == DEV_ADDR_ANY)
+			    && (new->rname[0] == '\0') && (new->ppp_open)) {
+				/* Yes !!! Get it.. */
+				DEBUG(IRDA_SERV_INFO, "Socket 0x%p is free.\n",
+				      new);
+				break;
+			}
+			new =
+			    (irnet_socket *) hashbin_get_next(irnet_server.
+							      list);
+		}
 	}
-    }
 
-  /* Spin lock end */
-  spin_unlock_bh(&irnet_server.spinlock);
+	/* Spin lock end */
+	spin_unlock_bh(&irnet_server.spinlock);
 
-  DEXIT(IRDA_SERV_TRACE, " - new = 0x%p\n", new);
-  return new;
+	DEXIT(IRDA_SERV_TRACE, " - new = 0x%p\n", new);
+	return new;
 }
 
 /*------------------------------------------------------------------*/
@@ -803,71 +804,68 @@ irnet_find_socket(irnet_socket *	self)
  *
  */
 static inline int
-irnet_connect_socket(irnet_socket *	server,
-		     irnet_socket *	new,
-		     struct qos_info *	qos,
-		     __u32		max_sdu_size,
-		     __u8		max_header_size)
+irnet_connect_socket(irnet_socket * server,
+		     irnet_socket * new,
+		     struct qos_info *qos,
+		     __u32 max_sdu_size, __u8 max_header_size)
 {
-  DENTER(IRDA_SERV_TRACE, "(server=0x%p, new=0x%p)\n",
-	 server, new);
-
-  /* Now attach up the new socket */
-  new->tsap = irttp_dup(server->tsap, new);
-  DABORT(new->tsap == NULL, -1, IRDA_SERV_ERROR, "dup failed!\n");
-
-  /* Set up all the relevant parameters on the new socket */
-  new->stsap_sel = new->tsap->stsap_sel;
-  new->dtsap_sel = new->tsap->dtsap_sel;
-  new->saddr = irttp_get_saddr(new->tsap);
-  new->daddr = irttp_get_daddr(new->tsap);
-
-  new->max_header_size = max_header_size;
-  new->max_sdu_size_tx = max_sdu_size;
-  new->max_data_size   = max_sdu_size;
-#ifdef STREAM_COMPAT
-  /* If we want to receive "stream sockets" */
-  if(max_sdu_size == 0)
-    new->max_data_size = irttp_get_max_seg_size(new->tsap);
-#endif /* STREAM_COMPAT */
-
-  /* Clean up the original one to keep it in listen state */
-  irttp_listen(server->tsap);
-
-  /* Send a connection response on the new socket */
-  irttp_connect_response(new->tsap, new->max_sdu_size_rx, NULL);
-
-  /* Allow PPP to send its junk over the new socket... */
-  set_bit(0, &new->ttp_open);
-
-  /* Not connecting anymore, and clean up last possible remains
-   * of connection attempts on the socket */
-  clear_bit(0, &new->ttp_connect);
-  if(new->iriap)
-    {
-      iriap_close(new->iriap);
-      new->iriap = NULL;
-    }
-  if(new->discoveries != NULL)
-    {
-      kfree(new->discoveries);
-      new->discoveries = NULL;
-    }
+	DENTER(IRDA_SERV_TRACE, "(server=0x%p, new=0x%p)\n", server, new);
+
+	/* Now attach up the new socket */
+	new->tsap = irttp_dup(server->tsap, new);
+	DABORT(new->tsap == NULL, -1, IRDA_SERV_ERROR, "dup failed!\n");
 
+	/* Set up all the relevant parameters on the new socket */
+	new->stsap_sel = new->tsap->stsap_sel;
+	new->dtsap_sel = new->tsap->dtsap_sel;
+	new->saddr = irttp_get_saddr(new->tsap);
+	new->daddr = irttp_get_daddr(new->tsap);
+
+	new->max_header_size = max_header_size;
+	new->max_sdu_size_tx = max_sdu_size;
+	new->max_data_size = max_sdu_size;
+#ifdef STREAM_COMPAT
+	/* If we want to receive "stream sockets" */
+	if (max_sdu_size == 0)
+		new->max_data_size = irttp_get_max_seg_size(new->tsap);
+#endif				/* STREAM_COMPAT */
+
+	/* Clean up the original one to keep it in listen state */
+	irttp_listen(server->tsap);
+
+	/* Send a connection response on the new socket */
+	irttp_connect_response(new->tsap, new->max_sdu_size_rx, NULL);
+
+	/* Allow PPP to send its junk over the new socket... */
+	set_bit(0, &new->ttp_open);
+
+	/* Not connecting anymore, and clean up last possible remains
+	 * of connection attempts on the socket */
+	clear_bit(0, &new->ttp_connect);
+	if (new->iriap) {
+		iriap_close(new->iriap);
+		new->iriap = NULL;
+	}
+	if (new->discoveries != NULL) {
+		kfree(new->discoveries);
+		new->discoveries = NULL;
+	}
 #ifdef CONNECT_INDIC_KICK
-  /* As currently we don't block packets in ppp_irnet_send() while passive,
-   * this is not really needed...
-   * Also, not doing it give IrDA a chance to finish the setup properly
-   * before being swamped with packets... */
-  ppp_output_wakeup(&new->chan);
-#endif /* CONNECT_INDIC_KICK */
-
-  /* Notify the control channel */
-  irnet_post_event(new, IRNET_CONNECT_FROM,
-		   new->saddr, new->daddr, server->rname, 0);
-
-  DEXIT(IRDA_SERV_TRACE, "\n");
-  return 0;
+	/*
+	 * As currently we don't block packets in ppp_irnet_send()
+	 * while passive, this is not really needed...
+	 * Also, not doing it give IrDA a chance to finish the setup properly
+	 * before being swamped with packets...
+	 */
+	ppp_output_wakeup(&new->chan);
+#endif				/* CONNECT_INDIC_KICK */
+
+	/* Notify the control channel */
+	irnet_post_event(new, IRNET_CONNECT_FROM,
+			 new->saddr, new->daddr, server->rname, 0);
+
+	DEXIT(IRDA_SERV_TRACE, "\n");
+	return 0;
 }
 
 /*------------------------------------------------------------------*/
@@ -878,30 +876,29 @@ irnet_connect_socket(irnet_socket *	server,
  *
  */
 static inline void
-irnet_disconnect_server(irnet_socket *	self,
-			struct sk_buff *skb)
+irnet_disconnect_server(irnet_socket * self, struct sk_buff *skb)
 {
-  DENTER(IRDA_SERV_TRACE, "(self=0x%p)\n", self);
+	DENTER(IRDA_SERV_TRACE, "(self=0x%p)\n", self);
 
-  /* Put the received packet in the black hole */
-  kfree_skb(skb);
+	/* Put the received packet in the black hole */
+	kfree_skb(skb);
 
 #ifdef FAIL_SEND_DISCONNECT
-  /* Tell the other party we don't want to be connected */
-  /* Hum... Is it the right thing to do ? And do we need to send
-   * a connect response before ? It looks ok without this... */
-  irttp_disconnect_request(self->tsap, NULL, P_NORMAL);
-#endif /* FAIL_SEND_DISCONNECT */
+	/* Tell the other party we don't want to be connected */
+	/* Hum... Is it the right thing to do ? And do we need to send
+	 * a connect response before ? It looks ok without this... */
+	irttp_disconnect_request(self->tsap, NULL, P_NORMAL);
+#endif				/* FAIL_SEND_DISCONNECT */
 
-  /* Notify the control channel (see irnet_find_socket()) */
-  irnet_post_event(NULL, IRNET_REQUEST_FROM,
-		   self->saddr, self->daddr, self->rname, 0);
+	/* Notify the control channel (see irnet_find_socket()) */
+	irnet_post_event(NULL, IRNET_REQUEST_FROM,
+			 self->saddr, self->daddr, self->rname, 0);
 
-  /* Clean up the server to keep it in listen state */
-  irttp_listen(self->tsap);
+	/* Clean up the server to keep it in listen state */
+	irttp_listen(self->tsap);
 
-  DEXIT(IRDA_SERV_TRACE, "\n");
-  return;
+	DEXIT(IRDA_SERV_TRACE, "\n");
+	return;
 }
 
 /*------------------------------------------------------------------*/
@@ -913,51 +910,53 @@ irnet_disconnect_server(irnet_socket *	self,
  * Register the IrLAN hint bit, create a IrTTP instance for us,
  * set all the IrTTP callbacks and create an IrIAS entry...
  */
-static inline int
-irnet_setup_server(void)
+static inline int irnet_setup_server(void)
 {
-  __u16		hints;
+	__u16 hints;
 
-  DENTER(IRDA_SERV_TRACE, "()\n");
+	DENTER(IRDA_SERV_TRACE, "()\n");
 
-  /* Initialise the regular socket part of the server */
-  irda_irnet_create(&irnet_server.s);
+	/* Initialise the regular socket part of the server */
+	irda_irnet_create(&irnet_server.s);
 
-  /* Open a local TSAP (an IrTTP instance) for the server */
-  irnet_open_tsap(&irnet_server.s);
+	/* Open a local TSAP (an IrTTP instance) for the server */
+	irnet_open_tsap(&irnet_server.s);
 
-  /* PPP part setup */
-  irnet_server.s.ppp_open = 0;
-  irnet_server.s.chan.private = NULL;
-  irnet_server.s.file = NULL;
+	/* PPP part setup */
+	irnet_server.s.ppp_open = 0;
+	irnet_server.s.chan.private = NULL;
+	irnet_server.s.file = NULL;
 
-  /* Get the hint bit corresponding to IrLAN */
-  /* Note : we overload the IrLAN hint bit. As it is only a "hint", and as
-   * we provide roughly the same functionality as IrLAN, this is ok.
-   * In fact, the situation is similar as JetSend overloading the Obex hint
-   */
-  hints = irlmp_service_to_hint(S_LAN);
+	/* Get the hint bit corresponding to IrLAN */
+	/*
+	 * Note : we overload the IrLAN hint bit. As it is only a "hint",
+	 * and as we provide roughly the same functionality as IrLAN,
+	 * this is ok. In fact, the situation is similar as JetSend
+	 * overloading the Obex hint
+	 */
+	hints = irlmp_service_to_hint(S_LAN);
 
 #ifdef ADVERTISE_HINT
-  /* Register with IrLMP as a service (advertise our hint bit) */
-  irnet_server.skey = irlmp_register_service(hints);
-#endif /* ADVERTISE_HINT */
+	/* Register with IrLMP as a service (advertise our hint bit) */
+	irnet_server.skey = irlmp_register_service(hints);
+#endif				/* ADVERTISE_HINT */
 
-  /* Register with LM-IAS (so that people can connect to us) */
-  irnet_server.ias_obj = irias_new_object(IRNET_SERVICE_NAME, jiffies);
-  irias_add_integer_attrib(irnet_server.ias_obj, IRNET_IAS_VALUE,
-			   irnet_server.s.stsap_sel, IAS_KERNEL_ATTR);
-  irias_insert_object(irnet_server.ias_obj);
+	/* Register with LM-IAS (so that people can connect to us) */
+	irnet_server.ias_obj = irias_new_object(IRNET_SERVICE_NAME, jiffies);
+	irias_add_integer_attrib(irnet_server.ias_obj, IRNET_IAS_VALUE,
+				 irnet_server.s.stsap_sel, IAS_KERNEL_ATTR);
+	irias_insert_object(irnet_server.ias_obj);
 
 #ifdef DISCOVERY_EVENTS
-  /* Tell IrLMP we want to be notified of newly discovered nodes */
-  irlmp_update_client(irnet_server.s.ckey, hints,
-		      irnet_discovery_indication, irnet_expiry_indication,
-		      (void *) &irnet_server.s);
+	/* Tell IrLMP we want to be notified of newly discovered nodes */
+	irlmp_update_client(irnet_server.s.ckey, hints,
+			    irnet_discovery_indication,
+			    irnet_expiry_indication,
+			    (void *)&irnet_server.s);
 #endif
 
-  DEXIT(IRDA_SERV_TRACE, " - self=0x%p\n", &irnet_server.s);
-  return 0;
+	DEXIT(IRDA_SERV_TRACE, " - self=0x%p\n", &irnet_server.s);
+	return 0;
 }
 
 /*------------------------------------------------------------------*/
@@ -968,28 +967,26 @@ irnet_setup_server(void)
  *
  * Reverse of the previous function...
  */
-static inline void
-irnet_destroy_server(void)
+static inline void irnet_destroy_server(void)
 {
-  DENTER(IRDA_SERV_TRACE, "()\n");
+	DENTER(IRDA_SERV_TRACE, "()\n");
 
 #ifdef ADVERTISE_HINT
-  /* Unregister with IrLMP */
-  irlmp_unregister_service(irnet_server.skey);
-#endif /* ADVERTISE_HINT */
+	/* Unregister with IrLMP */
+	irlmp_unregister_service(irnet_server.skey);
+#endif				/* ADVERTISE_HINT */
 
-  /* Unregister with LM-IAS */
-  if(irnet_server.ias_obj)
-    irias_delete_object(irnet_server.ias_obj);
+	/* Unregister with LM-IAS */
+	if (irnet_server.ias_obj)
+		irias_delete_object(irnet_server.ias_obj);
 
-  /* Cleanup the socket part */
-  irda_irnet_destroy(&irnet_server.s);
+	/* Cleanup the socket part */
+	irda_irnet_destroy(&irnet_server.s);
 
-  DEXIT(IRDA_SERV_TRACE, "\n");
-  return;
+	DEXIT(IRDA_SERV_TRACE, "\n");
+	return;
 }
 
-
 /************************ IRDA-TTP CALLBACKS ************************/
 /*
  * When we create a IrTTP instance, we pass to it a set of callbacks
@@ -1004,62 +1001,55 @@ irnet_destroy_server(void)
  *    Received some data from TinyTP. Just queue it on the receive queue
  *
  */
-static int
-irnet_data_indication(void *	instance,
-		      void *	sap,
-		      struct sk_buff *skb)
+static int irnet_data_indication(void *instance, void *sap,
+				 struct sk_buff *skb)
 {
-  irnet_socket *	ap = (irnet_socket *) instance;
-  unsigned char *	p;
-  int			code = 0;
-
-  DENTER(IRDA_TCB_TRACE, "(self/ap=0x%p, skb=0x%p)\n",
-	 ap, skb);
-  DASSERT(skb != NULL, 0, IRDA_CB_ERROR, "skb is NULL !!!\n");
-
-  /* Check is ppp is ready to receive our packet */
-  if(!ap->ppp_open)
-    {
-      DERROR(IRDA_CB_ERROR, "PPP not ready, dropping packet...\n");
-      /* When we return error, TTP will need to requeue the skb and
-       * will stop the sender. IrTTP will stall until we send it a
-       * flow control request... */
-      return -ENOMEM;
-    }
-
-  /* strip address/control field if present */
-  p = skb->data;
-  if((p[0] == PPP_ALLSTATIONS) && (p[1] == PPP_UI))
-    {
-      /* chop off address/control */
-      if(skb->len < 3)
-	goto err_exit;
-      p = skb_pull(skb, 2);
-    }
-
-  /* decompress protocol field if compressed */
-  if(p[0] & 1)
-    {
-      /* protocol is compressed */
-      skb_push(skb, 1)[0] = 0;
-    }
-  else
-    if(skb->len < 2)
-      goto err_exit;
-
-  /* pass to generic ppp layer */
-  /* Note : how do I know if ppp can accept or not the packet ? This is
-   * essential if I want to manage flow control smoothly... */
-  ppp_input(&ap->chan, skb);
-
-  DEXIT(IRDA_TCB_TRACE, "\n");
-  return 0;
-
- err_exit:
-  DERROR(IRDA_CB_ERROR, "Packet too small, dropping...\n");
-  kfree_skb(skb);
-  ppp_input_error(&ap->chan, code);
-  return 0;	/* Don't return an error code, only for flow control... */
+	irnet_socket *ap = (irnet_socket *) instance;
+	unsigned char *p;
+	int code = 0;
+
+	DENTER(IRDA_TCB_TRACE, "(self/ap=0x%p, skb=0x%p)\n", ap, skb);
+	DASSERT(skb != NULL, 0, IRDA_CB_ERROR, "skb is NULL !!!\n");
+
+	/* Check is ppp is ready to receive our packet */
+	if (!ap->ppp_open) {
+		DERROR(IRDA_CB_ERROR, "PPP not ready, dropping packet...\n");
+		/* When we return error, TTP will need to requeue the skb and
+		 * will stop the sender. IrTTP will stall until we send it a
+		 * flow control request... */
+		return -ENOMEM;
+	}
+
+	/* strip address/control field if present */
+	p = skb->data;
+	if ((p[0] == PPP_ALLSTATIONS) && (p[1] == PPP_UI)) {
+		/* chop off address/control */
+		if (skb->len < 3)
+			goto err_exit;
+		p = skb_pull(skb, 2);
+	}
+
+	/* decompress protocol field if compressed */
+	if (p[0] & 1) {
+		/* protocol is compressed */
+		skb_push(skb, 1)[0] = 0;
+	} else if (skb->len < 2)
+		goto err_exit;
+
+	/* pass to generic ppp layer */
+	/* Note : how do I know if ppp can accept or not the packet ? This is
+	 * essential if I want to manage flow control smoothly... */
+	ppp_input(&ap->chan, skb);
+
+	DEXIT(IRDA_TCB_TRACE, "\n");
+	return 0;
+
+      err_exit:
+	DERROR(IRDA_CB_ERROR, "Packet too small, dropping...\n");
+	kfree_skb(skb);
+	ppp_input_error(&ap->chan, code);
+	return 0;
+	/* Don't return an error code, only for flow control... */
 }
 
 /*------------------------------------------------------------------*/
@@ -1075,86 +1065,89 @@ irnet_data_indication(void *	instance,
  *	o connection request on the server not handled
  */
 static void
-irnet_disconnect_indication(void *	instance,
-			    void *	sap,
-			    LM_REASON	reason,
-			    struct sk_buff *skb)
+irnet_disconnect_indication(void *instance,
+			    void *sap, LM_REASON reason, struct sk_buff *skb)
 {
-  irnet_socket *	self = (irnet_socket *) instance;
-  int			test_open;
-  int			test_connect;
-
-  DENTER(IRDA_TCB_TRACE, "(self=0x%p)\n", self);
-  DASSERT(self != NULL, , IRDA_CB_ERROR, "Self is NULL !!!\n");
-
-  /* Don't care about it, but let's not leak it */
-  if(skb)
-    dev_kfree_skb(skb);
-
-  /* Prevent higher layer from accessing IrTTP */
-  test_open = test_and_clear_bit(0, &self->ttp_open);
-  /* Not connecting anymore...
-   * (note : TSAP is open, so IAP callbacks are no longer pending...) */
-  test_connect = test_and_clear_bit(0, &self->ttp_connect);
-
-  /* If both self->ttp_open and self->ttp_connect are NULL, it mean that we
-   * have a race condition with irda_irnet_destroy() or
-   * irnet_connect_indication(), so don't mess up tsap...
-   */
-  if(!(test_open || test_connect))
-    {
-      DERROR(IRDA_CB_ERROR, "Race condition detected...\n");
-      return;
-    }
-
-  /* If we were active, notify the control channel */
-  if(test_open)
-    irnet_post_event(self, IRNET_DISCONNECT_FROM,
-		     self->saddr, self->daddr, self->rname, 0);
-  else
-    /* If we were trying to connect, notify the control channel */
-    if((self->tsap) && (self != &irnet_server.s))
-      irnet_post_event(self, IRNET_NOANSWER_FROM,
-		       self->saddr, self->daddr, self->rname, 0);
-
-  /* Close our IrTTP connection, cleanup tsap */
-  if((self->tsap) && (self != &irnet_server.s))
-    {
-      DEBUG(IRDA_CB_INFO, "Closing our TTP connection.\n");
-      irttp_close_tsap(self->tsap);
-      self->tsap = NULL;
-    }
-  /* Cleanup the socket in case we want to reconnect in ppp_output_wakeup() */
-  self->stsap_sel = 0;
-  self->daddr = DEV_ADDR_ANY;
-  self->tx_flow = FLOW_START;
-
-  /* Deal with the ppp instance if it's still alive */
-  if(self->ppp_open)
-    {
-      if(test_open)
-	{
+	irnet_socket *self = (irnet_socket *) instance;
+	int test_open;
+	int test_connect;
+
+	DENTER(IRDA_TCB_TRACE, "(self=0x%p)\n", self);
+	DASSERT(self != NULL,, IRDA_CB_ERROR, "Self is NULL !!!\n");
+
+	/* Don't care about it, but let's not leak it */
+	if (skb)
+		dev_kfree_skb(skb);
+
+	/* Prevent higher layer from accessing IrTTP */
+	test_open = test_and_clear_bit(0, &self->ttp_open);
+	/* Not connecting anymore...
+	 * (note : TSAP is open, so IAP callbacks are no longer pending...) */
+	test_connect = test_and_clear_bit(0, &self->ttp_connect);
+
+	/*
+	 * If both self->ttp_open and self->ttp_connect are NULL,
+	 * it means that we
+	 * have a race condition with irda_irnet_destroy() or
+	 * irnet_connect_indication(), so don't mess up tsap...
+	 */
+	if (!(test_open || test_connect)) {
+		DERROR(IRDA_CB_ERROR, "Race condition detected...\n");
+		return;
+	}
+
+	/* If we were active, notify the control channel */
+	if (test_open)
+		irnet_post_event(self, IRNET_DISCONNECT_FROM,
+				 self->saddr, self->daddr, self->rname, 0);
+	else
+		/* If we were trying to connect, notify the control channel */
+	if ((self->tsap) && (self != &irnet_server.s))
+		irnet_post_event(self, IRNET_NOANSWER_FROM,
+				 self->saddr, self->daddr, self->rname, 0);
+
+	/* Close our IrTTP connection, cleanup tsap */
+	if ((self->tsap) && (self != &irnet_server.s)) {
+		DEBUG(IRDA_CB_INFO, "Closing our TTP connection.\n");
+		irttp_close_tsap(self->tsap);
+		self->tsap = NULL;
+	}
+	/*
+	 * Cleanup the socket in case we want to reconnect
+	 * in ppp_output_wakeup()
+	 */
+	self->stsap_sel = 0;
+	self->daddr = DEV_ADDR_ANY;
+	self->tx_flow = FLOW_START;
+
+	/* Deal with the ppp instance if it's still alive */
+	if (self->ppp_open) {
+		if (test_open) {
 #ifdef MISSING_PPP_API
-	  /* ppp_unregister_channel() wants a user context, which we
-	   * are guaranteed to NOT have here. What are we supposed
-	   * to do here ? Jean II */
-	  /* If we were connected, cleanup & close the PPP channel,
-	   * which will kill pppd (hangup) and the rest */
-	  ppp_unregister_channel(&self->chan);
-	  self->ppp_open = 0;
+			/*
+			 * ppp_unregister_channel() wants a user context,
+			 * which we are guaranteed to NOT have here.
+			 * What are we supposed to do here ? Jean II */
+			/*
+			 * If we were connected, cleanup & close the PPP
+			 * channel, which will kill pppd (hangup) and the rest.
+			 */
+			ppp_unregister_channel(&self->chan);
+			self->ppp_open = 0;
 #endif
+		} else {
+			/*
+			 * If we were trying to connect, flush (drain)
+			 * ppp_generic Tx queue (most often we have
+			 * blocked it), which will trigger an other attempt
+			 * to connect. If we are passive, this will empty
+			 * the Tx queue after last try.
+			 */
+			ppp_output_wakeup(&self->chan);
+		}
 	}
-      else
-	{
-	  /* If we were trying to connect, flush (drain) ppp_generic
-	   * Tx queue (most often we have blocked it), which will
-	   * trigger an other attempt to connect. If we are passive,
-	   * this will empty the Tx queue after last try. */
-	  ppp_output_wakeup(&self->chan);
-	}
-    }
 
-  DEXIT(IRDA_TCB_TRACE, "\n");
+	DEXIT(IRDA_TCB_TRACE, "\n");
 }
 
 /*------------------------------------------------------------------*/
@@ -1165,64 +1158,65 @@ irnet_disconnect_indication(void *	instance,
  *
  */
 static void
-irnet_connect_confirm(void *	instance,
-		      void *	sap,
+irnet_connect_confirm(void *instance,
+		      void *sap,
 		      struct qos_info *qos,
-		      __u32	max_sdu_size,
-		      __u8	max_header_size,
-		      struct sk_buff *skb)
+		      __u32 max_sdu_size,
+		      __u8 max_header_size, struct sk_buff *skb)
 {
-  irnet_socket *	self = (irnet_socket *) instance;
+	irnet_socket *self = (irnet_socket *) instance;
 
-  DENTER(IRDA_TCB_TRACE, "(self=0x%p)\n", self);
+	DENTER(IRDA_TCB_TRACE, "(self=0x%p)\n", self);
 
-  /* Check if socket is closing down (via irda_irnet_destroy()) */
-  if(! test_bit(0, &self->ttp_connect))
-    {
-      DERROR(IRDA_CB_ERROR, "Socket no longer connecting. Ouch !\n");
-      return;
-    }
+	/* Check if socket is closing down (via irda_irnet_destroy()) */
+	if (!test_bit(0, &self->ttp_connect)) {
+		DERROR(IRDA_CB_ERROR, "Socket no longer connecting. Ouch !\n");
+		return;
+	}
 
-  /* How much header space do we need to reserve */
-  self->max_header_size = max_header_size;
+	/* How much header space do we need to reserve */
+	self->max_header_size = max_header_size;
 
-  /* IrTTP max SDU size in transmit direction */
-  self->max_sdu_size_tx = max_sdu_size;
-  self->max_data_size = max_sdu_size;
+	/* IrTTP max SDU size in transmit direction */
+	self->max_sdu_size_tx = max_sdu_size;
+	self->max_data_size = max_sdu_size;
 #ifdef STREAM_COMPAT
-  if(max_sdu_size == 0)
-    self->max_data_size = irttp_get_max_seg_size(self->tsap);
-#endif /* STREAM_COMPAT */
-
-  /* At this point, IrLMP has assigned our source address */
-  self->saddr = irttp_get_saddr(self->tsap);
-
-  /* Allow higher layer to access IrTTP */
-  set_bit(0, &self->ttp_open);
-  clear_bit(0, &self->ttp_connect);	/* Not racy, IrDA traffic is serial */
-  /* Give a kick in the ass of ppp_generic so that he sends us some data */
-  ppp_output_wakeup(&self->chan);
-
-  /* Check size of received packet */
-  if(skb->len > 0)
-    {
-#ifdef PASS_CONNECT_PACKETS
-      DEBUG(IRDA_CB_INFO, "Passing connect packet to PPP.\n");
-      /* Try to pass it to PPP */
-      irnet_data_indication(instance, sap, skb);
-#else /* PASS_CONNECT_PACKETS */
-      DERROR(IRDA_CB_ERROR, "Dropping non empty packet.\n");
-      kfree_skb(skb);	/* Note : will be optimised with other kfree... */
-#endif /* PASS_CONNECT_PACKETS */
-    }
-  else
-    kfree_skb(skb);
-
-  /* Notify the control channel */
-  irnet_post_event(self, IRNET_CONNECT_TO,
-		   self->saddr, self->daddr, self->rname, 0);
+	if (max_sdu_size == 0)
+		self->max_data_size = irttp_get_max_seg_size(self->tsap);
+#endif				/* STREAM_COMPAT */
+
+	/* At this point, IrLMP has assigned our source address */
+	self->saddr = irttp_get_saddr(self->tsap);
+
+	/* Allow higher layer to access IrTTP */
+	set_bit(0, &self->ttp_open);
+	clear_bit(0, &self->ttp_connect);
+	/* Not racy, IrDA traffic is serial */
+	/*
+	 * Give a kick in the ass to ppp_generic so that he
+	 * sends us some data
+	 */
+	ppp_output_wakeup(&self->chan);
 
-  DEXIT(IRDA_TCB_TRACE, "\n");
+	/* Check size of received packet */
+	if (skb->len > 0) {
+#ifdef PASS_CONNECT_PACKETS
+		DEBUG(IRDA_CB_INFO, "Passing connect packet to PPP.\n");
+		/* Try to pass it to PPP */
+		irnet_data_indication(instance, sap, skb);
+#else				/* PASS_CONNECT_PACKETS */
+		DERROR(IRDA_CB_ERROR, "Dropping non empty packet.\n");
+		kfree_skb(skb);
+		/* Note : will be optimised with other kfree... */
+#endif		/* PASS_CONNECT_PACKETS */
+	} else
+		kfree_skb(skb);
+
+	/* Notify the control channel */
+	irnet_post_event(self, IRNET_CONNECT_TO,
+			 self->saddr, self->daddr, self->rname, 0);
+
+	DEXIT(IRDA_TCB_TRACE, "\n");
 }
 
 /*------------------------------------------------------------------*/
@@ -1232,39 +1226,36 @@ irnet_connect_confirm(void *	instance,
  *    Used by TinyTP to tell us if it can accept more data or not
  *
  */
-static void
-irnet_flow_indication(void *	instance,
-		      void *	sap,
-		      LOCAL_FLOW flow)
+static void irnet_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 {
-  irnet_socket *	self = (irnet_socket *) instance;
-  LOCAL_FLOW		oldflow = self->tx_flow;
-
-  DENTER(IRDA_TCB_TRACE, "(self=0x%p, flow=%d)\n", self, flow);
-
-  /* Update our state */
-  self->tx_flow = flow;
+	irnet_socket *self = (irnet_socket *) instance;
+	LOCAL_FLOW oldflow = self->tx_flow;
+
+	DENTER(IRDA_TCB_TRACE, "(self=0x%p, flow=%d)\n", self, flow);
+
+	/* Update our state */
+	self->tx_flow = flow;
+
+	/* Check what IrTTP want us to do... */
+	switch (flow) {
+	case FLOW_START:
+		DEBUG(IRDA_CB_INFO, "IrTTP wants us to start again\n");
+		/* Check if we really need to wake up PPP */
+		if (oldflow == FLOW_STOP)
+			ppp_output_wakeup(&self->chan);
+		else
+			DEBUG(IRDA_CB_INFO,
+			      "But we were already transmitting !!!\n");
+		break;
+	case FLOW_STOP:
+		DEBUG(IRDA_CB_INFO, "IrTTP wants us to slow down\n");
+		break;
+	default:
+		DEBUG(IRDA_CB_INFO, "Unknown flow command!\n");
+		break;
+	}
 
-  /* Check what IrTTP want us to do... */
-  switch(flow)
-    {
-    case FLOW_START:
-      DEBUG(IRDA_CB_INFO, "IrTTP wants us to start again\n");
-      /* Check if we really need to wake up PPP */
-      if(oldflow == FLOW_STOP)
-	ppp_output_wakeup(&self->chan);
-      else
-	DEBUG(IRDA_CB_INFO, "But we were already transmitting !!!\n");
-      break;
-    case FLOW_STOP:
-      DEBUG(IRDA_CB_INFO, "IrTTP wants us to slow down\n");
-      break;
-    default:
-      DEBUG(IRDA_CB_INFO, "Unknown flow command!\n");
-      break;
-    }
-
-  DEXIT(IRDA_TCB_TRACE, "\n");
+	DEXIT(IRDA_TCB_TRACE, "\n");
 }
 
 /*------------------------------------------------------------------*/
@@ -1275,32 +1266,29 @@ irnet_flow_indication(void *	instance,
  *
  */
 static void
-irnet_status_indication(void *	instance,
-			LINK_STATUS link,
-			LOCK_STATUS lock)
+irnet_status_indication(void *instance, LINK_STATUS link, LOCK_STATUS lock)
 {
-  irnet_socket *	self = (irnet_socket *) instance;
-
-  DENTER(IRDA_TCB_TRACE, "(self=0x%p)\n", self);
-  DASSERT(self != NULL, , IRDA_CB_ERROR, "Self is NULL !!!\n");
-
-  /* We can only get this event if we are connected */
-  switch(link)
-    {
-    case STATUS_NO_ACTIVITY:
-      irnet_post_event(self, IRNET_BLOCKED_LINK,
-		       self->saddr, self->daddr, self->rname, 0);
-      break;
-    default:
-      DEBUG(IRDA_CB_INFO, "Unknown status...\n");
-    }
-
-  DEXIT(IRDA_TCB_TRACE, "\n");
+	irnet_socket *self = (irnet_socket *) instance;
+
+	DENTER(IRDA_TCB_TRACE, "(self=0x%p)\n", self);
+	DASSERT(self != NULL,, IRDA_CB_ERROR, "Self is NULL !!!\n");
+
+	/* We can only get this event if we are connected */
+	switch (link) {
+	case STATUS_NO_ACTIVITY:
+		irnet_post_event(self, IRNET_BLOCKED_LINK,
+				 self->saddr, self->daddr, self->rname, 0);
+		break;
+	default:
+		DEBUG(IRDA_CB_INFO, "Unknown status...\n");
+	}
+
+	DEXIT(IRDA_TCB_TRACE, "\n");
 }
 
 /*------------------------------------------------------------------*/
 /*
- * Function irnet_connect_indication(instance, sap, qos, max_sdu_size, userdata)
+ * Function irnet_connect_indication(instance,sap,qos,max_sdu_size,userdata)
  *
  *    Incoming connection
  *
@@ -1313,137 +1301,146 @@ irnet_status_indication(void *	instance,
  * exist only one irnet connection.
  */
 static void
-irnet_connect_indication(void *		instance,
-			 void *		sap,
+irnet_connect_indication(void *instance,
+			 void *sap,
 			 struct qos_info *qos,
-			 __u32		max_sdu_size,
-			 __u8		max_header_size,
-			 struct sk_buff *skb)
+			 __u32 max_sdu_size,
+			 __u8 max_header_size, struct sk_buff *skb)
 {
-  irnet_socket *	server = &irnet_server.s;
-  irnet_socket *	new = (irnet_socket *) NULL;
-
-  DENTER(IRDA_TCB_TRACE, "(server=0x%p)\n", server);
-  DASSERT(instance == &irnet_server, , IRDA_CB_ERROR,
-	  "Invalid instance (0x%p) !!!\n", instance);
-  DASSERT(sap == irnet_server.s.tsap, , IRDA_CB_ERROR, "Invalid sap !!!\n");
-
-  /* Try to find the most appropriate IrNET socket */
-  new = irnet_find_socket(server);
-
-  /* After all this hard work, do we have an socket ? */
-  if(new == (irnet_socket *) NULL)
-    {
-      DEXIT(IRDA_CB_INFO, ": No socket waiting for this connection.\n");
-      irnet_disconnect_server(server, skb);
-      return;
-    }
-
-  /* Is the socket already busy ? */
-  if(test_bit(0, &new->ttp_open))
-    {
-      DEXIT(IRDA_CB_INFO, ": Socket already connected.\n");
-      irnet_disconnect_server(server, skb);
-      return;
-    }
-
-  /* The following code is a bit tricky, so need comments ;-)
-   */
-  /* If ttp_connect is set, the socket is trying to connect to the other
-   * end and may have sent a IrTTP connection request and is waiting for
-   * a connection response (that may never come).
-   * Now, the pain is that the socket may have opened a tsap and is
-   * waiting on it, while the other end is trying to connect to it on
-   * another tsap.
-   * Because IrNET can be peer to peer, we need to workaround this.
-   * Furthermore, the way the irnetd script is implemented, the
-   * target will create a second IrNET connection back to the
-   * originator and expect the originator to bind this new connection
-   * to the original PPPD instance.
-   * And of course, if we don't use irnetd, we can have a race when
-   * both side try to connect simultaneously, which could leave both
-   * connections half closed (yuck).
-   * Conclusions :
-   *	1) The "originator" must accept the new connection and get rid
-   *	   of the old one so that irnetd works
-   *	2) One side must deny the new connection to avoid races,
-   *	   but both side must agree on which side it is...
-   * Most often, the originator is primary at the LAP layer.
-   * Jean II
-   */
-  /* Now, let's look at the way I wrote the test...
-   * We need to clear up the ttp_connect flag atomically to prevent
-   * irnet_disconnect_indication() to mess up the tsap we are going to close.
-   * We want to clear the ttp_connect flag only if we close the tsap,
-   * otherwise we will never close it, so we need to check for primary
-   * *before* doing the test on the flag.
-   * And of course, ALLOW_SIMULT_CONNECT can disable this entirely...
-   * Jean II
-   */
-
-  /* Socket already connecting ? On primary ? */
-  if(0
-#ifdef ALLOW_SIMULT_CONNECT
-     || ((irttp_is_primary(server->tsap) == 1)	/* primary */
-	 && (test_and_clear_bit(0, &new->ttp_connect)))
-#endif /* ALLOW_SIMULT_CONNECT */
-     )
-    {
-      DERROR(IRDA_CB_ERROR, "Socket already connecting, but going to reuse it !\n");
-
-      /* Cleanup the old TSAP if necessary - IrIAP will be cleaned up later */
-      if(new->tsap != NULL)
-	{
-	  /* Close the old connection the new socket was attempting,
-	   * so that we can hook it up to the new connection.
-	   * It's now safe to do it... */
-	  irttp_close_tsap(new->tsap);
-	  new->tsap = NULL;
+	irnet_socket *server = &irnet_server.s;
+	irnet_socket *new = (irnet_socket *) NULL;
+
+	DENTER(IRDA_TCB_TRACE, "(server=0x%p)\n", server);
+	DASSERT(instance == &irnet_server,, IRDA_CB_ERROR,
+		"Invalid instance (0x%p) !!!\n", instance);
+	DASSERT(sap == irnet_server.s.tsap,, IRDA_CB_ERROR,
+		"Invalid sap !!!\n");
+
+	/* Try to find the most appropriate IrNET socket */
+	new = irnet_find_socket(server);
+
+	/* After all this hard work, do we have an socket ? */
+	if (new == (irnet_socket *) NULL) {
+		DEXIT(IRDA_CB_INFO,
+		      ": No socket waiting for this connection.\n");
+		irnet_disconnect_server(server, skb);
+		return;
 	}
-    }
-  else
-    {
-      /* Three options :
-       * 1) socket was not connecting or connected : ttp_connect should be 0.
-       * 2) we don't want to connect the socket because we are secondary or
-       * ALLOW_SIMULT_CONNECT is undefined. ttp_connect should be 1.
-       * 3) we are half way in irnet_disconnect_indication(), and it's a
-       * nice race condition... Fortunately, we can detect that by checking
-       * if tsap is still alive. On the other hand, we can't be in
-       * irda_irnet_destroy() otherwise we would not have found this
-       * socket in the hashbin.
-       * Jean II */
-      if((test_bit(0, &new->ttp_connect)) || (new->tsap != NULL))
-	{
-	  /* Don't mess this socket, somebody else in in charge... */
-	  DERROR(IRDA_CB_ERROR, "Race condition detected, socket in use, abort connect...\n");
-	  irnet_disconnect_server(server, skb);
-	  return;
+
+	/* Is the socket already busy ? */
+	if (test_bit(0, &new->ttp_open)) {
+		DEXIT(IRDA_CB_INFO, ": Socket already connected.\n");
+		irnet_disconnect_server(server, skb);
+		return;
 	}
-    }
 
-  /* So : at this point, we have a socket, and it is idle. Good ! */
-  irnet_connect_socket(server, new, qos, max_sdu_size, max_header_size);
+	/* The following code is a bit tricky, so need comments ;-)
+	 */
+	/* If ttp_connect is set, the socket is trying to connect to the other
+	 * end and may have sent a IrTTP connection request and is waiting for
+	 * a connection response (that may never come).
+	 * Now, the pain is that the socket may have opened a tsap and is
+	 * waiting on it, while the other end is trying to connect to it on
+	 * another tsap.
+	 * Because IrNET can be peer to peer, we need to workaround this.
+	 * Furthermore, the way the irnetd script is implemented, the
+	 * target will create a second IrNET connection back to the
+	 * originator and expect the originator to bind this new connection
+	 * to the original PPPD instance.
+	 * And of course, if we don't use irnetd, we can have a race when
+	 * both side try to connect simultaneously, which could leave both
+	 * connections half closed (yuck).
+	 * Conclusions :
+	 *    1) The "originator" must accept the new connection and get rid
+	 *       of the old one so that irnetd works
+	 *    2) One side must deny the new connection to avoid races,
+	 *       but both side must agree on which side it is...
+	 * Most often, the originator is primary at the LAP layer.
+	 * Jean II
+	 */
+	/* Now, let's look at the way I wrote the test...
+	 * We need to clear up the ttp_connect flag atomically to prevent
+	 * irnet_disconnect_indication() to mess up the tsap we are going
+	 * to close.
+	 * We want to clear the ttp_connect flag only if we close the tsap,
+	 * otherwise we will never close it, so we need to check for primary
+	 * *before* doing the test on the flag.
+	 * And of course, ALLOW_SIMULT_CONNECT can disable this entirely...
+	 * Jean II
+	 */
+
+	/* Socket already connecting ? On primary ? */
+	if (0
+#ifdef ALLOW_SIMULT_CONNECT
+	    || ((irttp_is_primary(server->tsap) == 1)	/* primary */
+		&&(test_and_clear_bit(0, &new->ttp_connect)))
+#endif				/* ALLOW_SIMULT_CONNECT */
+	    ) {
+		DERROR(IRDA_CB_ERROR,
+		       "Socket already connecting, but going to reuse it !\n");
+
+		/*
+		 * Cleanup the old TSAP if necessary.
+		 * IrIAP will be cleaned up later.
+		 */
+		if (new->tsap != NULL) {
+			/*
+			 * Close the old connection the new socket was
+			 * attempting, so that we can hook it up to the
+			 * new connection.
+			 * It's now safe to do it...
+			 */
+			irttp_close_tsap(new->tsap);
+			new->tsap = NULL;
+		}
+	} else {
+		/*
+		 * Three options :
+		 * 1) socket was not connecting or connected : ttp_connect
+		 * should be 0.
+		 * 2) we don't want to connect the socket because we are
+		 * secondary or ALLOW_SIMULT_CONNECT is undefined.
+		 * ttp_connect should be 1.
+		 * 3) we are half way in irnet_disconnect_indication(), and
+		 * it's a nice race condition... Fortunately, we can detect
+		 * that by checking if tsap is still alive.
+		 * On the other hand, we can't be in irda_irnet_destroy()
+		 * otherwise we would not have found this socket in the
+		 * hashbin.
+		 * Jean II
+		 */
+		if ((test_bit(0, &new->ttp_connect)) || (new->tsap != NULL)) {
+			/*
+			 * Don't mess this socket,
+			 * somebody else in in charge...
+			 */
+			DERROR(IRDA_CB_ERROR,
+			       "Race condition detected, socket in use, abort connect...\n");
+			irnet_disconnect_server(server, skb);
+			return;
+		}
+	}
+
+	/* So : at this point, we have a socket, and it is idle. Good ! */
+	irnet_connect_socket(server, new, qos, max_sdu_size, max_header_size);
 
-  /* Check size of received packet */
-  if(skb->len > 0)
-    {
+	/* Check size of received packet */
+	if (skb->len > 0) {
 #ifdef PASS_CONNECT_PACKETS
-      DEBUG(IRDA_CB_INFO, "Passing connect packet to PPP.\n");
-      /* Try to pass it to PPP */
-      irnet_data_indication(new, new->tsap, skb);
-#else /* PASS_CONNECT_PACKETS */
-      DERROR(IRDA_CB_ERROR, "Dropping non empty packet.\n");
-      kfree_skb(skb);	/* Note : will be optimised with other kfree... */
+		DEBUG(IRDA_CB_INFO, "Passing connect packet to PPP.\n");
+		/* Try to pass it to PPP */
+		irnet_data_indication(new, new->tsap, skb);
+#else				/* PASS_CONNECT_PACKETS */
+		DERROR(IRDA_CB_ERROR, "Dropping non empty packet.\n");
+		kfree_skb(skb);
+		/* Note : will be optimised with other kfree... */
 #endif /* PASS_CONNECT_PACKETS */
-    }
-  else
-    kfree_skb(skb);
+	} else
+		kfree_skb(skb);
 
-  DEXIT(IRDA_TCB_TRACE, "\n");
+	DEXIT(IRDA_TCB_TRACE, "\n");
 }
 
-
 /********************** IRDA-IAS/LMP CALLBACKS **********************/
 /*
  * These are the callbacks called by other layers of the IrDA stack,
@@ -1462,46 +1459,45 @@ irnet_connect_indication(void *		instance,
  * on this TSAP.
  */
 static void
-irnet_getvalue_confirm(int	result,
-		       __u16	obj_id,
-		       struct ias_value *value,
-		       void *	priv)
+irnet_getvalue_confirm(int result,
+		       __u16 obj_id, struct ias_value *value, void *priv)
 {
-  irnet_socket *	self = (irnet_socket *) priv;
+	irnet_socket *self = (irnet_socket *) priv;
 
-  DENTER(IRDA_OCB_TRACE, "(self=0x%p)\n", self);
-  DASSERT(self != NULL, , IRDA_OCB_ERROR, "Self is NULL !!!\n");
+	DENTER(IRDA_OCB_TRACE, "(self=0x%p)\n", self);
+	DASSERT(self != NULL,, IRDA_OCB_ERROR, "Self is NULL !!!\n");
 
-  /* Check if already connected (via irnet_connect_socket())
-   * or socket is closing down (via irda_irnet_destroy()) */
-  if(! test_bit(0, &self->ttp_connect))
-    {
-      DERROR(IRDA_OCB_ERROR, "Socket no longer connecting. Ouch !\n");
-      return;
-    }
+	/* Check if already connected (via irnet_connect_socket())
+	 * or socket is closing down (via irda_irnet_destroy()) */
+	if (!test_bit(0, &self->ttp_connect)) {
+		DERROR(IRDA_OCB_ERROR,
+		       "Socket no longer connecting. Ouch !\n");
+		return;
+	}
 
-  /* We probably don't need to make any more queries */
-  iriap_close(self->iriap);
-  self->iriap = NULL;
+	/* We probably don't need to make any more queries */
+	iriap_close(self->iriap);
+	self->iriap = NULL;
 
-  /* Post process the IAS reply */
-  self->dtsap_sel = irnet_ias_to_tsap(self, result, value);
+	/* Post process the IAS reply */
+	self->dtsap_sel = irnet_ias_to_tsap(self, result, value);
 
-  /* If error, just go out */
-  if(self->errno)
-    {
-      clear_bit(0, &self->ttp_connect);
-      DERROR(IRDA_OCB_ERROR, "IAS connect failed ! (0x%X)\n", self->errno);
-      return;
-    }
+	/* If error, just go out */
+	if (self->errno) {
+		clear_bit(0, &self->ttp_connect);
+		DERROR(IRDA_OCB_ERROR, "IAS connect failed ! (0x%X)\n",
+		       self->errno);
+		return;
+	}
 
-  DEBUG(IRDA_OCB_INFO, "daddr = %08x, lsap = %d, starting IrTTP connection\n",
-	self->daddr, self->dtsap_sel);
+	DEBUG(IRDA_OCB_INFO,
+	      "daddr = %08x, lsap = %d, starting IrTTP connection\n",
+	      self->daddr, self->dtsap_sel);
 
-  /* Start up TTP - non blocking */
-  irnet_connect_tsap(self);
+	/* Start up TTP - non blocking */
+	irnet_connect_tsap(self);
 
-  DEXIT(IRDA_OCB_TRACE, "\n");
+	DEXIT(IRDA_OCB_TRACE, "\n");
 }
 
 /*------------------------------------------------------------------*/
@@ -1525,95 +1521,88 @@ irnet_getvalue_confirm(int	result,
  * any device and connect to it.
  */
 static void
-irnet_discovervalue_confirm(int		result,
-			    __u16	obj_id,
-			    struct ias_value *value,
-			    void *	priv)
+irnet_discovervalue_confirm(int result,
+			    __u16 obj_id, struct ias_value *value, void *priv)
 {
-  irnet_socket *	self = (irnet_socket *) priv;
-  __u8			dtsap_sel;		/* TSAP we are looking for */
-
-  DENTER(IRDA_OCB_TRACE, "(self=0x%p)\n", self);
-  DASSERT(self != NULL, , IRDA_OCB_ERROR, "Self is NULL !!!\n");
-
-  /* Check if already connected (via irnet_connect_socket())
-   * or socket is closing down (via irda_irnet_destroy()) */
-  if(! test_bit(0, &self->ttp_connect))
-    {
-      DERROR(IRDA_OCB_ERROR, "Socket no longer connecting. Ouch !\n");
-      return;
-    }
-
-  /* Post process the IAS reply */
-  dtsap_sel = irnet_ias_to_tsap(self, result, value);
-
-  /* Have we got something ? */
-  if(self->errno == 0)
-    {
-      /* We found the requested service */
-      if(self->daddr != DEV_ADDR_ANY)
-	{
-	  DERROR(IRDA_OCB_ERROR, "More than one device in range supports IrNET...\n");
+	irnet_socket *self = (irnet_socket *) priv;
+	__u8 dtsap_sel;		/* TSAP we are looking for */
+
+	DENTER(IRDA_OCB_TRACE, "(self=0x%p)\n", self);
+	DASSERT(self != NULL,, IRDA_OCB_ERROR, "Self is NULL !!!\n");
+
+	/* Check if already connected (via irnet_connect_socket())
+	 * or socket is closing down (via irda_irnet_destroy()) */
+	if (!test_bit(0, &self->ttp_connect)) {
+		DERROR(IRDA_OCB_ERROR,
+		       "Socket no longer connecting. Ouch !\n");
+		return;
 	}
-      else
-	{
-	  /* First time we found that one, save it ! */
-	  self->daddr = self->discoveries[self->disco_index].daddr;
-	  self->dtsap_sel = dtsap_sel;
+
+	/* Post process the IAS reply */
+	dtsap_sel = irnet_ias_to_tsap(self, result, value);
+
+	/* Have we got something ? */
+	if (self->errno == 0) {
+		/* We found the requested service */
+		if (self->daddr != DEV_ADDR_ANY) {
+			DERROR(IRDA_OCB_ERROR,
+			       "More than one device in range supports IrNET...\n");
+		} else {
+			/* First time we found that one, save it ! */
+			self->daddr =
+			    self->discoveries[self->disco_index].daddr;
+			self->dtsap_sel = dtsap_sel;
+		}
 	}
-    }
-
-  /* If no failure */
-  if((self->errno == -EADDRNOTAVAIL) || (self->errno == 0))
-    {
-      int	ret;
-
-      /* Search the next node */
-      ret = irnet_discover_next_daddr(self);
-      if(!ret)
-	{
-	  /* In this case, the above request was non-blocking.
-	   * We will return here after a while... */
-	  return;
+
+	/* If no failure */
+	if ((self->errno == -EADDRNOTAVAIL) || (self->errno == 0)) {
+		int ret;
+
+		/* Search the next node */
+		ret = irnet_discover_next_daddr(self);
+		if (!ret) {
+			/* In this case, the above request was non-blocking.
+			 * We will return here after a while... */
+			return;
+		}
+		/* In this case, we have processed the last discovery item */
 	}
-      /* In this case, we have processed the last discovery item */
-    }
-
-  /* No more queries to be done (failure or last one) */
-
-  /* We probably don't need to make any more queries */
-  iriap_close(self->iriap);
-  self->iriap = NULL;
-
-  /* No more items : remove the log and signal termination */
-  DEBUG(IRDA_OCB_INFO, "Cleaning up log (0x%p)\n",
-	self->discoveries);
-  if(self->discoveries != NULL)
-    {
-      /* Cleanup our copy of the discovery log */
-      kfree(self->discoveries);
-      self->discoveries = NULL;
-    }
-  self->disco_number = -1;
-
-  /* Check out what we found */
-  if(self->daddr == DEV_ADDR_ANY)
-    {
-      self->daddr = DEV_ADDR_ANY;
-      clear_bit(0, &self->ttp_connect);
-      DEXIT(IRDA_OCB_TRACE, ": cannot discover IrNET in any device !!!\n");
-      return;
-    }
-
-  /* We have a valid address - just connect */
-
-  DEBUG(IRDA_OCB_INFO, "daddr = %08x, lsap = %d, starting IrTTP connection\n",
-	self->daddr, self->dtsap_sel);
-
-  /* Start up TTP - non blocking */
-  irnet_connect_tsap(self);
-
-  DEXIT(IRDA_OCB_TRACE, "\n");
+
+	/* No more queries to be done (failure or last one) */
+
+	/* We probably don't need to make any more queries */
+	iriap_close(self->iriap);
+	self->iriap = NULL;
+
+	/* No more items : remove the log and signal termination */
+	DEBUG(IRDA_OCB_INFO, "Cleaning up log (0x%p)\n", self->discoveries);
+	if (self->discoveries != NULL) {
+		/* Cleanup our copy of the discovery log */
+		kfree(self->discoveries);
+		self->discoveries = NULL;
+	}
+	self->disco_number = -1;
+
+	/* Check out what we found */
+	if (self->daddr == DEV_ADDR_ANY) {
+		self->daddr = DEV_ADDR_ANY;
+		clear_bit(0, &self->ttp_connect);
+		DEXIT(IRDA_OCB_TRACE,
+		      ": cannot discover IrNET in any device !!!\n");
+		return;
+	}
+
+	/* We have a valid address - just connect */
+
+	DEBUG(IRDA_OCB_INFO,
+	      "daddr = %08x, lsap = %d, starting IrTTP connection\n",
+	      self->daddr, self->dtsap_sel);
+
+	/* Start up TTP - non blocking */
+	irnet_connect_tsap(self);
+
+	DEXIT(IRDA_OCB_TRACE, "\n");
 }
 
 #ifdef DISCOVERY_EVENTS
@@ -1640,25 +1629,24 @@ irnet_discovervalue_confirm(int		result,
  * is to messy, so we leave that to user space...
  */
 static void
-irnet_discovery_indication(discinfo_t *		discovery,
-			   DISCOVERY_MODE	mode,
-			   void *		priv)
+irnet_discovery_indication(discinfo_t * discovery,
+			   DISCOVERY_MODE mode, void *priv)
 {
-  irnet_socket *	self = &irnet_server.s;
+	irnet_socket *self = &irnet_server.s;
 
-  DENTER(IRDA_OCB_TRACE, "(self=0x%p)\n", self);
-  DASSERT(priv == &irnet_server, , IRDA_OCB_ERROR,
-	  "Invalid instance (0x%p) !!!\n", priv);
+	DENTER(IRDA_OCB_TRACE, "(self=0x%p)\n", self);
+	DASSERT(priv == &irnet_server,, IRDA_OCB_ERROR,
+		"Invalid instance (0x%p) !!!\n", priv);
 
-  DEBUG(IRDA_OCB_INFO, "Discovered new IrNET/IrLAN node %s...\n",
-	discovery->info);
+	DEBUG(IRDA_OCB_INFO, "Discovered new IrNET/IrLAN node %s...\n",
+	      discovery->info);
 
-  /* Notify the control channel */
-  irnet_post_event(NULL, IRNET_DISCOVER,
-		   discovery->saddr, discovery->daddr, discovery->info,
-		   u16ho(discovery->hints));
+	/* Notify the control channel */
+	irnet_post_event(NULL, IRNET_DISCOVER,
+			 discovery->saddr, discovery->daddr, discovery->info,
+			 u16ho(discovery->hints));
 
-  DEXIT(IRDA_OCB_TRACE, "\n");
+	DEXIT(IRDA_OCB_TRACE, "\n");
 }
 
 /*------------------------------------------------------------------*/
@@ -1671,28 +1659,24 @@ irnet_discovery_indication(discinfo_t *		discovery,
  * check if it is a "new" node...
  */
 static void
-irnet_expiry_indication(discinfo_t *	expiry,
-			DISCOVERY_MODE	mode,
-			void *		priv)
+irnet_expiry_indication(discinfo_t * expiry, DISCOVERY_MODE mode, void *priv)
 {
-  irnet_socket *	self = &irnet_server.s;
+	irnet_socket *self = &irnet_server.s;
 
-  DENTER(IRDA_OCB_TRACE, "(self=0x%p)\n", self);
-  DASSERT(priv == &irnet_server, , IRDA_OCB_ERROR,
-	  "Invalid instance (0x%p) !!!\n", priv);
+	DENTER(IRDA_OCB_TRACE, "(self=0x%p)\n", self);
+	DASSERT(priv == &irnet_server,, IRDA_OCB_ERROR,
+		"Invalid instance (0x%p) !!!\n", priv);
 
-  DEBUG(IRDA_OCB_INFO, "IrNET/IrLAN node %s expired...\n",
-	expiry->info);
+	DEBUG(IRDA_OCB_INFO, "IrNET/IrLAN node %s expired...\n", expiry->info);
 
-  /* Notify the control channel */
-  irnet_post_event(NULL, IRNET_EXPIRE,
-		   expiry->saddr, expiry->daddr, expiry->info,
-		   u16ho(expiry->hints));
+	/* Notify the control channel */
+	irnet_post_event(NULL, IRNET_EXPIRE,
+			 expiry->saddr, expiry->daddr, expiry->info,
+			 u16ho(expiry->hints));
 
-  DEXIT(IRDA_OCB_TRACE, "\n");
+	DEXIT(IRDA_OCB_TRACE, "\n");
 }
-#endif /* DISCOVERY_EVENTS */
-
+#endif				/* DISCOVERY_EVENTS */
 
 /*********************** PROC ENTRY CALLBACKS ***********************/
 /*
@@ -1707,88 +1691,84 @@ irnet_expiry_indication(discinfo_t *	expiry,
  *
  *    Give some info to the /proc file system
  */
-static int
-irnet_proc_read(char *	buf,
-		char **	start,
-		off_t	offset,
-		int	len)
+static int irnet_proc_read(char *buf, char **start, off_t offset, int len)
 {
-  irnet_socket *	self;
-  char *		state;
-  int			i = 0;
-
-  len = 0;
-
-  /* Get the IrNET server information... */
-  len += sprintf(buf+len, "IrNET server - ");
-  len += sprintf(buf+len, "IrDA state: %s, ",
-		 (irnet_server.running ? "running" : "dead"));
-  len += sprintf(buf+len, "stsap_sel: %02x, ", irnet_server.s.stsap_sel);
-  len += sprintf(buf+len, "dtsap_sel: %02x\n", irnet_server.s.dtsap_sel);
-
-  /* Do we need to continue ? */
-  if(!irnet_server.running)
-    return len;
-
-  /* Protect access to the instance list */
-  spin_lock_bh(&irnet_server.spinlock);
-
-  /* Get the sockets one by one... */
-  self = (irnet_socket *) hashbin_get_first(irnet_server.list);
-  while(self != NULL)
-    {
-      /* Start printing info about the socket. */
-      len += sprintf(buf+len, "\nIrNET socket %d - ", i++);
-
-      /* First, get the requested configuration */
-      len += sprintf(buf+len, "Requested IrDA name: \"%s\", ", self->rname);
-      len += sprintf(buf+len, "daddr: %08x, ", self->rdaddr);
-      len += sprintf(buf+len, "saddr: %08x\n", self->rsaddr);
-
-      /* Second, get all the PPP info */
-      len += sprintf(buf+len, "	PPP state: %s",
-		 (self->ppp_open ? "registered" : "unregistered"));
-      if(self->ppp_open)
-	{
-	  len += sprintf(buf+len, ", unit: ppp%d",
-			 ppp_unit_number(&self->chan));
-	  len += sprintf(buf+len, ", channel: %d",
-			 ppp_channel_index(&self->chan));
-	  len += sprintf(buf+len, ", mru: %d",
-			 self->mru);
-	  /* Maybe add self->flags ? Later... */
+	irnet_socket *self;
+	char *state;
+	int i = 0;
+
+	len = 0;
+
+	/* Get the IrNET server information... */
+	len += sprintf(buf + len, "IrNET server - ");
+	len += sprintf(buf + len, "IrDA state: %s, ",
+		       (irnet_server.running ? "running" : "dead"));
+	len +=
+	    sprintf(buf + len, "stsap_sel: %02x, ", irnet_server.s.stsap_sel);
+	len +=
+	    sprintf(buf + len, "dtsap_sel: %02x\n", irnet_server.s.dtsap_sel);
+
+	/* Do we need to continue ? */
+	if (!irnet_server.running)
+		return len;
+
+	/* Protect access to the instance list */
+	spin_lock_bh(&irnet_server.spinlock);
+
+	/* Get the sockets one by one... */
+	self = (irnet_socket *) hashbin_get_first(irnet_server.list);
+	while (self != NULL) {
+		/* Start printing info about the socket. */
+		len += sprintf(buf + len, "\nIrNET socket %d - ", i++);
+
+		/* First, get the requested configuration */
+		len +=
+		    sprintf(buf + len, "Requested IrDA name: \"%s\", ",
+			    self->rname);
+		len += sprintf(buf + len, "daddr: %08x, ", self->rdaddr);
+		len += sprintf(buf + len, "saddr: %08x\n", self->rsaddr);
+
+		/* Second, get all the PPP info */
+		len += sprintf(buf + len, "	PPP state: %s",
+			       (self->
+				ppp_open ? "registered" : "unregistered"));
+		if (self->ppp_open) {
+			len += sprintf(buf + len, ", unit: ppp%d",
+				       ppp_unit_number(&self->chan));
+			len += sprintf(buf + len, ", channel: %d",
+				       ppp_channel_index(&self->chan));
+			len += sprintf(buf + len, ", mru: %d", self->mru);
+			/* Maybe add self->flags ? Later... */
+		}
+
+		/* Then, get all the IrDA specific info... */
+		if (self->ttp_open)
+			state = "connected";
+		else if (self->tsap != NULL)
+			state = "connecting";
+		else if (self->iriap != NULL)
+			state = "searching";
+		else if (self->ttp_connect)
+			state = "weird";
+		else
+			state = "idle";
+		len += sprintf(buf + len, "\n	IrDA state: %s, ", state);
+		len += sprintf(buf + len, "daddr: %08x, ", self->daddr);
+		len += sprintf(buf + len, "stsap_sel: %02x, ",
+			       self->stsap_sel);
+		len += sprintf(buf + len, "dtsap_sel: %02x\n",
+			       self->dtsap_sel);
+
+		/* Next socket, please... */
+		self = (irnet_socket *) hashbin_get_next(irnet_server.list);
 	}
 
-      /* Then, get all the IrDA specific info... */
-      if(self->ttp_open)
-	state = "connected";
-      else
-	if(self->tsap != NULL)
-	  state = "connecting";
-	else
-	  if(self->iriap != NULL)
-	    state = "searching";
-	  else
-	    if(self->ttp_connect)
-	      state = "weird";
-	    else
-	      state = "idle";
-      len += sprintf(buf+len, "\n	IrDA state: %s, ", state);
-      len += sprintf(buf+len, "daddr: %08x, ", self->daddr);
-      len += sprintf(buf+len, "stsap_sel: %02x, ", self->stsap_sel);
-      len += sprintf(buf+len, "dtsap_sel: %02x\n", self->dtsap_sel);
-
-      /* Next socket, please... */
-      self = (irnet_socket *) hashbin_get_next(irnet_server.list);
-    }
-
-  /* Spin lock end */
-  spin_unlock_bh(&irnet_server.spinlock);
-
-  return len;
-}
-#endif /* PROC_FS */
+	/* Spin lock end */
+	spin_unlock_bh(&irnet_server.spinlock);
 
+	return len;
+}
+#endif				/* PROC_FS */
 
 /********************** CONFIGURATION/CLEANUP **********************/
 /*
@@ -1800,67 +1780,65 @@ irnet_proc_read(char *	buf,
 /*
  * Prepare the IrNET layer for operation...
  */
-int __init
-irda_irnet_init(void)
+int __init irda_irnet_init(void)
 {
-  int		err = 0;
+	int err = 0;
 
-  DENTER(MODULE_TRACE, "()\n");
+	DENTER(MODULE_TRACE, "()\n");
 
-  /* Pure paranoia - should be redundant */
-  memset(&irnet_server, 0, sizeof(struct irnet_root));
+	/* Pure paranoia - should be redundant */
+	memset(&irnet_server, 0, sizeof(struct irnet_root));
 
-  /* Setup start of irnet instance list */
-  irnet_server.list = hashbin_new(HB_NOLOCK);
-  DABORT(irnet_server.list == NULL, -ENOMEM,
-	 MODULE_ERROR, "Can't allocate hashbin!\n");
-  /* Init spinlock for instance list */
-  spin_lock_init(&irnet_server.spinlock);
+	/* Setup start of irnet instance list */
+	irnet_server.list = hashbin_new(HB_NOLOCK);
+	DABORT(irnet_server.list == NULL, -ENOMEM,
+	       MODULE_ERROR, "Can't allocate hashbin!\n");
+	/* Init spinlock for instance list */
+	spin_lock_init(&irnet_server.spinlock);
 
-  /* Initialise control channel */
-  init_waitqueue_head(&irnet_events.rwait);
-  irnet_events.index = 0;
-  /* Init spinlock for event logging */
-  spin_lock_init(&irnet_events.spinlock);
+	/* Initialise control channel */
+	init_waitqueue_head(&irnet_events.rwait);
+	irnet_events.index = 0;
+	/* Init spinlock for event logging */
+	spin_lock_init(&irnet_events.spinlock);
 
 #ifdef CONFIG_PROC_FS
-  /* Add a /proc file for irnet infos */
-  create_proc_info_entry("irnet", 0, proc_irda, irnet_proc_read);
-#endif /* CONFIG_PROC_FS */
+	/* Add a /proc file for irnet infos */
+	create_proc_info_entry("irnet", 0, proc_irda, irnet_proc_read);
+#endif				/* CONFIG_PROC_FS */
 
-  /* Setup the IrNET server */
-  err = irnet_setup_server();
+	/* Setup the IrNET server */
+	err = irnet_setup_server();
 
-  if(!err)
-    /* We are no longer functional... */
-    irnet_server.running = 1;
+	if (!err)
+		/* We are no longer functional... */
+		irnet_server.running = 1;
 
-  DEXIT(MODULE_TRACE, "\n");
-  return err;
+	DEXIT(MODULE_TRACE, "\n");
+	return err;
 }
 
 /*------------------------------------------------------------------*/
 /*
  * Cleanup at exit...
  */
-void __exit
-irda_irnet_cleanup(void)
+void __exit irda_irnet_cleanup(void)
 {
-  DENTER(MODULE_TRACE, "()\n");
+	DENTER(MODULE_TRACE, "()\n");
 
-  /* We are no longer there... */
-  irnet_server.running = 0;
+	/* We are no longer there... */
+	irnet_server.running = 0;
 
 #ifdef CONFIG_PROC_FS
-  /* Remove our /proc file */
-  remove_proc_entry("irnet", proc_irda);
-#endif /* CONFIG_PROC_FS */
+	/* Remove our /proc file */
+	remove_proc_entry("irnet", proc_irda);
+#endif				/* CONFIG_PROC_FS */
 
-  /* Remove our IrNET server from existence */
-  irnet_destroy_server();
+	/* Remove our IrNET server from existence */
+	irnet_destroy_server();
 
-  /* Remove all instances of IrNET socket still present */
-  hashbin_delete(irnet_server.list, (FREE_FUNC) irda_irnet_destroy);
+	/* Remove all instances of IrNET socket still present */
+	hashbin_delete(irnet_server.list, (FREE_FUNC) irda_irnet_destroy);
 
-  DEXIT(MODULE_TRACE, "\n");
+	DEXIT(MODULE_TRACE, "\n");
 }
diff --git a/net/irda/irnet/irnet_irda.h b/net/irda/irnet/irnet_irda.h
index 0ba92d0..16b2af3 100644
--- a/net/irda/irnet/irnet_irda.h
+++ b/net/irda/irnet/irnet_irda.h
@@ -38,149 +38,91 @@
  * the IrNET server (listen for connection requests) and the root
  * of the IrNET socket list
  */
-typedef struct irnet_root
-{
-  irnet_socket		s;		/* To pretend we are a client... */
+typedef struct irnet_root {
+	irnet_socket s;		/* To pretend we are a client... */
 
-  /* Generic stuff */
-  int			magic;		/* Paranoia */
-  int			running;	/* Are we operational ? */
+	/* Generic stuff */
+	int magic;		/* Paranoia */
+	int running;		/* Are we operational ? */
 
-  /* Link list of all IrNET instances opened */
-  hashbin_t *		list;
-  spinlock_t		spinlock;	/* Serialize access to the list */
-  /* Note : the way hashbin has been designed is absolutely not
-   * reentrant, beware... So, we blindly protect all with spinlock */
+	/* Link list of all IrNET instances opened */
+	hashbin_t *list;
+	spinlock_t spinlock;	/* Serialize access to the list */
+	/* Note : the way hashbin has been designed is absolutely not
+	 * reentrant, beware... So, we blindly protect all with spinlock */
 
-  /* Handle for the hint bit advertised in IrLMP */
-  void *		skey;
+	/* Handle for the hint bit advertised in IrLMP */
+	void *skey;
 
-  /* Server socket part */
-  struct ias_object *	ias_obj;	/* Our service name + lsap in IAS */
+	/* Server socket part */
+	struct ias_object *ias_obj;	/* Our service name + lsap in IAS */
 
 } irnet_root;
 
-
 /**************************** PROTOTYPES ****************************/
 
 /* ----------------------- CONTROL CHANNEL ----------------------- */
 static void
-	irnet_post_event(irnet_socket *,
-			 irnet_event,
-			 __u32,
-			 __u32,
-			 char *,
-			 __u16);
+irnet_post_event(irnet_socket *, irnet_event, __u32, __u32, char *, __u16);
 /* ----------------------- IRDA SUBROUTINES ----------------------- */
-static inline int
-	irnet_open_tsap(irnet_socket *);
-static inline __u8
-	irnet_ias_to_tsap(irnet_socket *,
-			  int,
-			  struct ias_value *);
-static inline int
-	irnet_find_lsap_sel(irnet_socket *);
-static inline int
-	irnet_connect_tsap(irnet_socket *);
-static inline int
-	irnet_discover_next_daddr(irnet_socket *);
-static inline int
-	irnet_discover_daddr_and_lsap_sel(irnet_socket *);
-static inline int
-	irnet_dname_to_daddr(irnet_socket *);
+static inline int irnet_open_tsap(irnet_socket *);
+static inline __u8 irnet_ias_to_tsap(irnet_socket *, int, struct ias_value *);
+static inline int irnet_find_lsap_sel(irnet_socket *);
+static inline int irnet_connect_tsap(irnet_socket *);
+static inline int irnet_discover_next_daddr(irnet_socket *);
+static inline int irnet_discover_daddr_and_lsap_sel(irnet_socket *);
+static inline int irnet_dname_to_daddr(irnet_socket *);
 /* ------------------------ SERVER SOCKET ------------------------ */
+static inline int irnet_daddr_to_dname(irnet_socket *);
+static inline irnet_socket *irnet_find_socket(irnet_socket *);
 static inline int
-	irnet_daddr_to_dname(irnet_socket *);
-static inline irnet_socket *
-	irnet_find_socket(irnet_socket *);
-static inline int
-	irnet_connect_socket(irnet_socket *,
-			     irnet_socket *,
-			     struct qos_info *,
-			     __u32,
-			     __u8);
-static inline void
-	irnet_disconnect_server(irnet_socket *,
-				struct sk_buff *);
-static inline int
-	irnet_setup_server(void);
-static inline void
-	irnet_destroy_server(void);
+irnet_connect_socket(irnet_socket *,
+		     irnet_socket *, struct qos_info *, __u32, __u8);
+static inline void irnet_disconnect_server(irnet_socket *, struct sk_buff *);
+static inline int irnet_setup_server(void);
+static inline void irnet_destroy_server(void);
 /* ---------------------- IRDA-TTP CALLBACKS ---------------------- */
-static int
-	irnet_data_indication(void *,		/* instance */
-			      void *,		/* sap */
-			      struct sk_buff *);
-static void
-	irnet_disconnect_indication(void *,
-				    void *,
-				    LM_REASON,
-				    struct sk_buff *);
-static void
-	irnet_connect_confirm(void *,
-			      void *,
-			      struct qos_info *,
-			      __u32,
-			      __u8,
-			      struct sk_buff *);
+static int irnet_data_indication(void *,	/* instance */
+				 void *,	/* sap */
+				 struct sk_buff *);
 static void
-	irnet_flow_indication(void *,
-			      void *,
-			      LOCAL_FLOW);
+irnet_disconnect_indication(void *, void *, LM_REASON, struct sk_buff *);
 static void
-	irnet_status_indication(void *,
-				LINK_STATUS,
-				LOCK_STATUS);
+irnet_connect_confirm(void *,
+		      void *,
+		      struct qos_info *, __u32, __u8, struct sk_buff *);
+static void irnet_flow_indication(void *, void *, LOCAL_FLOW);
+static void irnet_status_indication(void *, LINK_STATUS, LOCK_STATUS);
 static void
-	irnet_connect_indication(void *,
-				 void *,
-				 struct qos_info *,
-				 __u32,
-				 __u8,
-				 struct sk_buff *);
+irnet_connect_indication(void *,
+			 void *,
+			 struct qos_info *, __u32, __u8, struct sk_buff *);
 /* -------------------- IRDA-IAS/LMP CALLBACKS -------------------- */
-static void
-	irnet_getvalue_confirm(int,
-			       __u16,
-			       struct ias_value *,
-			       void *);
-static void
-	irnet_discovervalue_confirm(int,
-				    __u16,
-				    struct ias_value *,
-				    void *);
+static void irnet_getvalue_confirm(int, __u16, struct ias_value *, void *);
+static void irnet_discovervalue_confirm(int, __u16,
+					struct ias_value *, void *);
 #ifdef DISCOVERY_EVENTS
-static void
-	irnet_discovery_indication(discinfo_t *,
-				   DISCOVERY_MODE,
-				   void *);
-static void
-	irnet_expiry_indication(discinfo_t *,
-				DISCOVERY_MODE,
-				void *);
+static void irnet_discovery_indication(discinfo_t *, DISCOVERY_MODE, void *);
+static void irnet_expiry_indication(discinfo_t *, DISCOVERY_MODE, void *);
 #endif
 /* -------------------------- PROC ENTRY -------------------------- */
 #ifdef CONFIG_PROC_FS
-static int
-	irnet_proc_read(char *,
-			char **,
-			off_t,
-			int);
-#endif /* CONFIG_PROC_FS */
+static int irnet_proc_read(char *, char **, off_t, int);
+#endif				/* CONFIG_PROC_FS */
 
 /**************************** VARIABLES ****************************/
 
 /*
  * The IrNET server. Listen to connection requests and co...
  */
-static struct irnet_root	irnet_server;
+static struct irnet_root irnet_server;
 
 /* Control channel stuff (note : extern) */
-struct irnet_ctrl_channel	irnet_events;
+struct irnet_ctrl_channel irnet_events;
 
 /* The /proc/net/irda directory, defined elsewhere... */
 #ifdef CONFIG_PROC_FS
 extern struct proc_dir_entry *proc_irda;
-#endif /* CONFIG_PROC_FS */
+#endif				/* CONFIG_PROC_FS */
 
-#endif /* IRNET_IRDA_H */
+#endif				/* IRNET_IRDA_H */
diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
index 2f9f8dc..9f4fa05 100644
--- a/net/irda/irnet/irnet_ppp.c
+++ b/net/irda/irnet/irnet_ppp.c
@@ -40,132 +40,137 @@ static struct ppp_channel_ops irnet_ppp_ops = {
  * Note : the code is crude, but effective...
  */
 static inline ssize_t
-irnet_ctrl_write(irnet_socket *	ap,
-		 const char __user *buf,
-		 size_t		count)
+irnet_ctrl_write(irnet_socket * ap, const char __user * buf, size_t count)
 {
-  char		command[IRNET_MAX_COMMAND];
-  char *	start;		/* Current command being processed */
-  char *	next;		/* Next command to process */
-  int		length;		/* Length of current command */
-
-  DENTER(CTRL_TRACE, "(ap=0x%p, count=%Zd)\n", ap, count);
-
-  /* Check for overflow... */
-  DABORT(count >= IRNET_MAX_COMMAND, -ENOMEM,
-	 CTRL_ERROR, "Too much data !!!\n");
-
-  /* Get the data in the driver */
-  if(copy_from_user(command, buf, count))
-    {
-      DERROR(CTRL_ERROR, "Invalid user space pointer.\n");
-      return -EFAULT;
-    }
-
-  /* Safe terminate the string */
-  command[count] = '\0';
-  DEBUG(CTRL_INFO, "Command line received is ``%s'' (%Zd).\n",
-	command, count);
-
-  /* Check every commands in the command line */
-  next = command;
-  while(next != NULL)
-    {
-      /* Look at the next command */
-      start = next;
-
-      /* Scrap whitespaces before the command */
-      while(isspace(*start))
-	start++;
-
-      /* ',' is our command separator */
-      next = strchr(start, ',');
-      if(next)
-	{
-	  *next = '\0';			/* Terminate command */
-	  length = next - start;	/* Length */
-	  next++;			/* Skip the '\0' */
-	}
-      else
-	length = strlen(start);
-
-      DEBUG(CTRL_INFO, "Found command ``%s'' (%d).\n", start, length);
-
-      /* Check if we recognised one of the known command
-       * We can't use "switch" with strings, so hack with "continue" */
-
-      /* First command : name -> Requested IrDA nickname */
-      if(!strncmp(start, "name", 4))
-	{
-	  /* Copy the name only if is included and not "any" */
-	  if((length > 5) && (strcmp(start + 5, "any")))
-	    {
-	      /* Strip out trailing whitespaces */
-	      while(isspace(start[length - 1]))
-		length--;
-
-	      /* Copy the name for later reuse */
-	      memcpy(ap->rname, start + 5, length - 5);
-	      ap->rname[length - 5] = '\0';
-	    }
-	  else
-	    ap->rname[0] = '\0';
-	  DEBUG(CTRL_INFO, "Got rname = ``%s''\n", ap->rname);
-
-	  /* Restart the loop */
-	  continue;
-	}
+	char command[IRNET_MAX_COMMAND];
+	char *start;		/* Current command being processed */
+	char *next;		/* Next command to process */
+	int length;		/* Length of current command */
 
-      /* Second command : addr, daddr -> Requested IrDA destination address
-       * Also process : saddr -> Requested IrDA source address */
-      if((!strncmp(start, "addr", 4)) ||
-	 (!strncmp(start, "daddr", 5)) ||
-	 (!strncmp(start, "saddr", 5)))
-	{
-	  __u32		addr = DEV_ADDR_ANY;
-
-	  /* Copy the address only if is included and not "any" */
-	  if((length > 5) && (strcmp(start + 5, "any")))
-	    {
-	      char *	begp = start + 5;
-	      char *	endp;
-
-	      /* Scrap whitespaces before the command */
-	      while(isspace(*begp))
-		begp++;
-
-	      /* Convert argument to a number (last arg is the base) */
-	      addr = simple_strtoul(begp, &endp, 16);
-	      /* Has it worked  ? (endp should be start + length) */
-	      DABORT(endp <= (start + 5), -EINVAL,
-		     CTRL_ERROR, "Invalid address.\n");
-	    }
-	  /* Which type of address ? */
-	  if(start[0] == 's')
-	    {
-	      /* Save it */
-	      ap->rsaddr = addr;
-	      DEBUG(CTRL_INFO, "Got rsaddr = %08x\n", ap->rsaddr);
-	    }
-	  else
-	    {
-	      /* Save it */
-	      ap->rdaddr = addr;
-	      DEBUG(CTRL_INFO, "Got rdaddr = %08x\n", ap->rdaddr);
-	    }
-
-	  /* Restart the loop */
-	  continue;
-	}
+	DENTER(CTRL_TRACE, "(ap=0x%p, count=%Zd)\n", ap, count);
 
-      /* Other possible command : connect N (number of retries) */
+	/* Check for overflow... */
+	DABORT(count >= IRNET_MAX_COMMAND, -ENOMEM,
+	       CTRL_ERROR, "Too much data !!!\n");
 
-      /* No command matched -> Failed... */
-      DABORT(1, -EINVAL, CTRL_ERROR, "Not a recognised IrNET command.\n");
-    }
+	/* Get the data in the driver */
+	if (copy_from_user(command, buf, count)) {
+		DERROR(CTRL_ERROR, "Invalid user space pointer.\n");
+		return -EFAULT;
+	}
+
+	/* Safe terminate the string */
+	command[count] = '\0';
+	DEBUG(CTRL_INFO, "Command line received is ``%s'' (%Zd).\n",
+	      command, count);
+
+	/* Check every commands in the command line */
+	next = command;
+	while (next != NULL) {
+		/* Look at the next command */
+		start = next;
+
+		/* Scrap whitespaces before the command */
+		while (isspace(*start))
+			start++;
+
+		/* ',' is our command separator */
+		next = strchr(start, ',');
+		if (next) {
+			*next = '\0';	/* Terminate command */
+			length = next - start;	/* Length */
+			next++;	/* Skip the '\0' */
+		} else
+			length = strlen(start);
+
+		DEBUG(CTRL_INFO, "Found command ``%s'' (%d).\n",
+		      start, length);
+
+		/*
+		 * Check if we recognised one of the known command
+		 * We can't use "switch" with strings, so hack
+		 * with "continue"
+		 */
+
+		/* First command : name -> Requested IrDA nickname */
+		if (!strncmp(start, "name", 4)) {
+			/* Copy the name only if is included and not "any" */
+			if ((length > 5) && (strcmp(start + 5, "any"))) {
+				/* Strip out trailing whitespaces */
+				while (isspace(start[length - 1]))
+					length--;
+
+				/* Copy the name for later reuse */
+				memcpy(ap->rname, start + 5, length - 5);
+				ap->rname[length - 5] = '\0';
+			} else
+				ap->rname[0] = '\0';
+			DEBUG(CTRL_INFO, "Got rname = ``%s''\n", ap->rname);
+
+			/* Restart the loop */
+			continue;
+		}
+
+		/*
+		 * Second command : addr, daddr -> Requested IrDA
+		 * destination address
+		 * Also process : saddr -> Requested IrDA source address
+		 */
+		if ((!strncmp(start, "addr", 4)) ||
+		    (!strncmp(start, "daddr", 5)) ||
+		    (!strncmp(start, "saddr", 5))) {
+			__u32 addr = DEV_ADDR_ANY;
+
+			/*
+			 * Copy the address only if
+			 * is included and not "any"
+			 */
+			if ((length > 5) && (strcmp(start + 5, "any"))) {
+				char *begp = start + 5;
+				char *endp;
+
+				/* Scrap whitespaces before the command */
+				while (isspace(*begp))
+					begp++;
+
+				/*
+				 * Convert argument to a number
+				 * (last arg is the base)
+				 */
+				addr = simple_strtoul(begp, &endp, 16);
+				/*
+				 * Has it worked ?
+				 * (endp should be start + length)
+				 */
+				DABORT(endp <= (start + 5), -EINVAL,
+				       CTRL_ERROR, "Invalid address.\n");
+			}
+			/* Which type of address ? */
+			if (start[0] == 's') {
+				/* Save it */
+				ap->rsaddr = addr;
+				DEBUG(CTRL_INFO, "Got rsaddr = %08x\n",
+				      ap->rsaddr);
+			} else {
+				/* Save it */
+				ap->rdaddr = addr;
+				DEBUG(CTRL_INFO, "Got rdaddr = %08x\n",
+				      ap->rdaddr);
+			}
+
+			/* Restart the loop */
+			continue;
+		}
+
+		/* Other possible command : connect N (number of retries) */
+
+		/* No command matched -> Failed... */
+		DABORT(1, -EINVAL, CTRL_ERROR,
+		       "Not a recognised IrNET command.\n");
+	}
 
-  /* Success : we have parsed all commands successfully */
-  return(count);
+	/* Success : we have parsed all commands successfully */
+	return (count);
 }
 
 #ifdef INITIAL_DISCOVERY
@@ -178,21 +183,20 @@ irnet_ctrl_write(irnet_socket *	ap,
  * This function query the current content of the discovery log
  * at the startup of the event channel and save it in the internal struct.
  */
-static void
-irnet_get_discovery_log(irnet_socket *	ap)
+static void irnet_get_discovery_log(irnet_socket * ap)
 {
-  __u16		mask = irlmp_service_to_hint(S_LAN);
+	__u16 mask = irlmp_service_to_hint(S_LAN);
 
-  /* Ask IrLMP for the current discovery log */
-  ap->discoveries = irlmp_get_discoveries(&ap->disco_number, mask,
-					  DISCOVERY_DEFAULT_SLOTS);
+	/* Ask IrLMP for the current discovery log */
+	ap->discoveries = irlmp_get_discoveries(&ap->disco_number, mask,
+						DISCOVERY_DEFAULT_SLOTS);
 
-  /* Check if the we got some results */
-  if(ap->discoveries == NULL)
-    ap->disco_number = -1;
+	/* Check if the we got some results */
+	if (ap->discoveries == NULL)
+		ap->disco_number = -1;
 
-  DEBUG(CTRL_INFO, "Got the log (0x%p), size is %d\n",
-	ap->discoveries, ap->disco_number);
+	DEBUG(CTRL_INFO, "Got the log (0x%p), size is %d\n",
+	      ap->discoveries, ap->disco_number);
 }
 
 /*------------------------------------------------------------------*/
@@ -210,205 +214,194 @@ irnet_get_discovery_log(irnet_socket *	ap)
  * While reading :    discoveries = ptr  ; disco_index = X ; disco_number = Y
  * After reading :    discoveries = NULL ; disco_index = Y ; disco_number = -1
  */
-static inline int
-irnet_read_discovery_log(irnet_socket *	ap,
-			 char *		event)
+static inline int irnet_read_discovery_log(irnet_socket * ap, char *event)
 {
-  int		done_event = 0;
-
-  DENTER(CTRL_TRACE, "(ap=0x%p, event=0x%p)\n",
-	 ap, event);
-
-  /* Test if we have some work to do or we have already finished */
-  if(ap->disco_number == -1)
-    {
-      DEBUG(CTRL_INFO, "Already done\n");
-      return 0;
-    }
-
-  /* Test if it's the first time and therefore we need to get the log */
-  if(ap->discoveries == NULL)
-    irnet_get_discovery_log(ap);
-
-  /* Check if we have more item to dump */
-  if(ap->disco_index < ap->disco_number)
-    {
-      /* Write an event */
-      sprintf(event, "Found %08x (%s) behind %08x {hints %02X-%02X}\n",
-	      ap->discoveries[ap->disco_index].daddr,
-	      ap->discoveries[ap->disco_index].info,
-	      ap->discoveries[ap->disco_index].saddr,
-	      ap->discoveries[ap->disco_index].hints[0],
-	      ap->discoveries[ap->disco_index].hints[1]);
-      DEBUG(CTRL_INFO, "Writing discovery %d : %s\n",
-	    ap->disco_index, ap->discoveries[ap->disco_index].info);
-
-      /* We have an event */
-      done_event = 1;
-      /* Next discovery */
-      ap->disco_index++;
-    }
-
-  /* Check if we have done the last item */
-  if(ap->disco_index >= ap->disco_number)
-    {
-      /* No more items : remove the log and signal termination */
-      DEBUG(CTRL_INFO, "Cleaning up log (0x%p)\n",
-	    ap->discoveries);
-      if(ap->discoveries != NULL)
-	{
-	  /* Cleanup our copy of the discovery log */
-	  kfree(ap->discoveries);
-	  ap->discoveries = NULL;
+	int done_event = 0;
+
+	DENTER(CTRL_TRACE, "(ap=0x%p, event=0x%p)\n", ap, event);
+
+	/* Test if we have some work to do or we have already finished */
+	if (ap->disco_number == -1) {
+		DEBUG(CTRL_INFO, "Already done\n");
+		return 0;
 	}
-      ap->disco_number = -1;
-    }
 
-  return done_event;
+	/* Test if it's the first time and therefore we need to get the log */
+	if (ap->discoveries == NULL)
+		irnet_get_discovery_log(ap);
+
+	/* Check if we have more item to dump */
+	if (ap->disco_index < ap->disco_number) {
+		/* Write an event */
+		sprintf(event,
+			"Found %08x (%s) behind %08x {hints %02X-%02X}\n",
+			ap->discoveries[ap->disco_index].daddr,
+			ap->discoveries[ap->disco_index].info,
+			ap->discoveries[ap->disco_index].saddr,
+			ap->discoveries[ap->disco_index].hints[0],
+			ap->discoveries[ap->disco_index].hints[1]);
+		DEBUG(CTRL_INFO, "Writing discovery %d : %s\n",
+		      ap->disco_index,
+		      ap->discoveries[ap->disco_index].info);
+
+		/* We have an event */
+		done_event = 1;
+		/* Next discovery */
+		ap->disco_index++;
+	}
+
+	/* Check if we have done the last item */
+	if (ap->disco_index >= ap->disco_number) {
+		/* No more items : remove the log and signal termination */
+		DEBUG(CTRL_INFO, "Cleaning up log (0x%p)\n", ap->discoveries);
+		if (ap->discoveries != NULL) {
+			/* Cleanup our copy of the discovery log */
+			kfree(ap->discoveries);
+			ap->discoveries = NULL;
+		}
+		ap->disco_number = -1;
+	}
+
+	return done_event;
 }
-#endif /* INITIAL_DISCOVERY */
+#endif				/* INITIAL_DISCOVERY */
 
 /*------------------------------------------------------------------*/
 /*
  * Read is used to get IrNET events
  */
 static inline ssize_t
-irnet_ctrl_read(irnet_socket *	ap,
-		struct file *	file,
-		char __user *	buf,
-		size_t		count)
+irnet_ctrl_read(irnet_socket * ap,
+		struct file *file, char __user * buf, size_t count)
 {
-  DECLARE_WAITQUEUE(wait, current);
-  char		event[64];	/* Max event is 61 char */
-  ssize_t	ret = 0;
+	DECLARE_WAITQUEUE(wait, current);
+	char event[64];		/* Max event is 61 char */
+	ssize_t ret = 0;
 
-  DENTER(CTRL_TRACE, "(ap=0x%p, count=%Zd)\n", ap, count);
+	DENTER(CTRL_TRACE, "(ap=0x%p, count=%Zd)\n", ap, count);
 
-  /* Check if we can write an event out in one go */
-  DABORT(count < sizeof(event), -EOVERFLOW, CTRL_ERROR, "Buffer to small.\n");
+	/* Check if we can write an event out in one go */
+	DABORT(count < sizeof(event), -EOVERFLOW, CTRL_ERROR,
+	       "Buffer to small.\n");
 
 #ifdef INITIAL_DISCOVERY
-  /* Check if we have read the log */
-  if(irnet_read_discovery_log(ap, event))
-    {
-      /* We have an event !!! Copy it to the user */
-      if(copy_to_user(buf, event, strlen(event)))
-	{
-	  DERROR(CTRL_ERROR, "Invalid user space pointer.\n");
-	  return -EFAULT;
+	/* Check if we have read the log */
+	if (irnet_read_discovery_log(ap, event)) {
+		/* We have an event !!! Copy it to the user */
+		if (copy_to_user(buf, event, strlen(event))) {
+			DERROR(CTRL_ERROR, "Invalid user space pointer.\n");
+			return -EFAULT;
+		}
+
+		DEXIT(CTRL_TRACE, "\n");
+		return (strlen(event));
+	}
+#endif				/* INITIAL_DISCOVERY */
+
+	/* Put ourselves on the wait queue to be woken up */
+	add_wait_queue(&irnet_events.rwait, &wait);
+	current->state = TASK_INTERRUPTIBLE;
+	for (;;) {
+		/* If there is unread events */
+		ret = 0;
+		if (ap->event_index != irnet_events.index)
+			break;
+		ret = -EAGAIN;
+		if (file->f_flags & O_NONBLOCK)
+			break;
+		ret = -ERESTARTSYS;
+		if (signal_pending(current))
+			break;
+		/* Yield and wait to be woken up */
+		schedule();
+	}
+	current->state = TASK_RUNNING;
+	remove_wait_queue(&irnet_events.rwait, &wait);
+
+	/* Did we got it ? */
+	if (ret != 0) {
+		/* No, return the error code */
+		DEXIT(CTRL_TRACE, " - ret %Zd\n", ret);
+		return ret;
+	}
+
+	/* Which event is it ? */
+	switch (irnet_events.log[ap->event_index].event) {
+	case IRNET_DISCOVER:
+		sprintf(event,
+			"Discovered %08x (%s) behind %08x {hints %02X-%02X}\n",
+			irnet_events.log[ap->event_index].daddr,
+			irnet_events.log[ap->event_index].name,
+			irnet_events.log[ap->event_index].saddr,
+			irnet_events.log[ap->event_index].hints.byte[0],
+			irnet_events.log[ap->event_index].hints.byte[1]);
+		break;
+	case IRNET_EXPIRE:
+		sprintf(event,
+			"Expired %08x (%s) behind %08x {hints %02X-%02X}\n",
+			irnet_events.log[ap->event_index].daddr,
+			irnet_events.log[ap->event_index].name,
+			irnet_events.log[ap->event_index].saddr,
+			irnet_events.log[ap->event_index].hints.byte[0],
+			irnet_events.log[ap->event_index].hints.byte[1]);
+		break;
+	case IRNET_CONNECT_TO:
+		sprintf(event, "Connected to %08x (%s) on ppp%d\n",
+			irnet_events.log[ap->event_index].daddr,
+			irnet_events.log[ap->event_index].name,
+			irnet_events.log[ap->event_index].unit);
+		break;
+	case IRNET_CONNECT_FROM:
+		sprintf(event, "Connection from %08x (%s) on ppp%d\n",
+			irnet_events.log[ap->event_index].daddr,
+			irnet_events.log[ap->event_index].name,
+			irnet_events.log[ap->event_index].unit);
+		break;
+	case IRNET_REQUEST_FROM:
+		sprintf(event, "Request from %08x (%s) behind %08x\n",
+			irnet_events.log[ap->event_index].daddr,
+			irnet_events.log[ap->event_index].name,
+			irnet_events.log[ap->event_index].saddr);
+		break;
+	case IRNET_NOANSWER_FROM:
+		sprintf(event, "No-answer from %08x (%s) on ppp%d\n",
+			irnet_events.log[ap->event_index].daddr,
+			irnet_events.log[ap->event_index].name,
+			irnet_events.log[ap->event_index].unit);
+		break;
+	case IRNET_BLOCKED_LINK:
+		sprintf(event, "Blocked link with %08x (%s) on ppp%d\n",
+			irnet_events.log[ap->event_index].daddr,
+			irnet_events.log[ap->event_index].name,
+			irnet_events.log[ap->event_index].unit);
+		break;
+	case IRNET_DISCONNECT_FROM:
+		sprintf(event, "Disconnection from %08x (%s) on ppp%d\n",
+			irnet_events.log[ap->event_index].daddr,
+			irnet_events.log[ap->event_index].name,
+			irnet_events.log[ap->event_index].unit);
+		break;
+	case IRNET_DISCONNECT_TO:
+		sprintf(event, "Disconnected to %08x (%s)\n",
+			irnet_events.log[ap->event_index].daddr,
+			irnet_events.log[ap->event_index].name);
+		break;
+	default:
+		sprintf(event, "Bug\n");
 	}
+	/* Increment our event index */
+	ap->event_index = (ap->event_index + 1) % IRNET_MAX_EVENTS;
 
-      DEXIT(CTRL_TRACE, "\n");
-      return(strlen(event));
-    }
-#endif /* INITIAL_DISCOVERY */
-
-  /* Put ourselves on the wait queue to be woken up */
-  add_wait_queue(&irnet_events.rwait, &wait);
-  current->state = TASK_INTERRUPTIBLE;
-  for(;;)
-    {
-      /* If there is unread events */
-      ret = 0;
-      if(ap->event_index != irnet_events.index)
-	break;
-      ret = -EAGAIN;
-      if(file->f_flags & O_NONBLOCK)
-	break;
-      ret = -ERESTARTSYS;
-      if(signal_pending(current))
-	break;
-      /* Yield and wait to be woken up */
-      schedule();
-    }
-  current->state = TASK_RUNNING;
-  remove_wait_queue(&irnet_events.rwait, &wait);
-
-  /* Did we got it ? */
-  if(ret != 0)
-    {
-      /* No, return the error code */
-      DEXIT(CTRL_TRACE, " - ret %Zd\n", ret);
-      return ret;
-    }
-
-  /* Which event is it ? */
-  switch(irnet_events.log[ap->event_index].event)
-    {
-    case IRNET_DISCOVER:
-      sprintf(event, "Discovered %08x (%s) behind %08x {hints %02X-%02X}\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].saddr,
-	      irnet_events.log[ap->event_index].hints.byte[0],
-	      irnet_events.log[ap->event_index].hints.byte[1]);
-      break;
-    case IRNET_EXPIRE:
-      sprintf(event, "Expired %08x (%s) behind %08x {hints %02X-%02X}\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].saddr,
-	      irnet_events.log[ap->event_index].hints.byte[0],
-	      irnet_events.log[ap->event_index].hints.byte[1]);
-      break;
-    case IRNET_CONNECT_TO:
-      sprintf(event, "Connected to %08x (%s) on ppp%d\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].unit);
-      break;
-    case IRNET_CONNECT_FROM:
-      sprintf(event, "Connection from %08x (%s) on ppp%d\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].unit);
-      break;
-    case IRNET_REQUEST_FROM:
-      sprintf(event, "Request from %08x (%s) behind %08x\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].saddr);
-      break;
-    case IRNET_NOANSWER_FROM:
-      sprintf(event, "No-answer from %08x (%s) on ppp%d\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].unit);
-      break;
-    case IRNET_BLOCKED_LINK:
-      sprintf(event, "Blocked link with %08x (%s) on ppp%d\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].unit);
-      break;
-    case IRNET_DISCONNECT_FROM:
-      sprintf(event, "Disconnection from %08x (%s) on ppp%d\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name,
-	      irnet_events.log[ap->event_index].unit);
-      break;
-    case IRNET_DISCONNECT_TO:
-      sprintf(event, "Disconnected to %08x (%s)\n",
-	      irnet_events.log[ap->event_index].daddr,
-	      irnet_events.log[ap->event_index].name);
-      break;
-    default:
-      sprintf(event, "Bug\n");
-    }
-  /* Increment our event index */
-  ap->event_index = (ap->event_index + 1) % IRNET_MAX_EVENTS;
-
-  DEBUG(CTRL_INFO, "Event is :%s", event);
-
-  /* Copy it to the user */
-  if(copy_to_user(buf, event, strlen(event)))
-    {
-      DERROR(CTRL_ERROR, "Invalid user space pointer.\n");
-      return -EFAULT;
-    }
-
-  DEXIT(CTRL_TRACE, "\n");
-  return(strlen(event));
+	DEBUG(CTRL_INFO, "Event is :%s", event);
+
+	/* Copy it to the user */
+	if (copy_to_user(buf, event, strlen(event))) {
+		DERROR(CTRL_ERROR, "Invalid user space pointer.\n");
+		return -EFAULT;
+	}
+
+	DEXIT(CTRL_TRACE, "\n");
+	return (strlen(event));
 }
 
 /*------------------------------------------------------------------*/
@@ -417,35 +410,34 @@ irnet_ctrl_read(irnet_socket *	ap,
  * Just check if there are new events...
  */
 static inline unsigned int
-irnet_ctrl_poll(irnet_socket *	ap,
-		struct file *	file,
-		poll_table *	wait)
+irnet_ctrl_poll(irnet_socket * ap, struct file *file, poll_table * wait)
 {
-  unsigned int mask;
+	unsigned int mask;
 
-  DENTER(CTRL_TRACE, "(ap=0x%p)\n", ap);
+	DENTER(CTRL_TRACE, "(ap=0x%p)\n", ap);
 
-  poll_wait(file, &irnet_events.rwait, wait);
-  mask = POLLOUT | POLLWRNORM;
-  /* If there is unread events */
-  if(ap->event_index != irnet_events.index)
-    mask |= POLLIN | POLLRDNORM;
+	poll_wait(file, &irnet_events.rwait, wait);
+	mask = POLLOUT | POLLWRNORM;
+	/* If there is unread events */
+	if (ap->event_index != irnet_events.index)
+		mask |= POLLIN | POLLRDNORM;
 #ifdef INITIAL_DISCOVERY
-  if(ap->disco_number != -1)
-    {
-      /* Test if it's the first time and therefore we need to get the log */
-      if(ap->discoveries == NULL)
-	irnet_get_discovery_log(ap);
-      /* Recheck */
-      if(ap->disco_number != -1)
-	mask |= POLLIN | POLLRDNORM;
-    }
-#endif /* INITIAL_DISCOVERY */
-
-  DEXIT(CTRL_TRACE, " - mask=0x%X\n", mask);
-  return mask;
-}
+	if (ap->disco_number != -1) {
+		/*
+		 * Test if it's the first time and therefore
+		 * we need to get the log
+		 */
+		if (ap->discoveries == NULL)
+			irnet_get_discovery_log(ap);
+		/* Recheck */
+		if (ap->disco_number != -1)
+			mask |= POLLIN | POLLRDNORM;
+	}
+#endif				/* INITIAL_DISCOVERY */
 
+	DEXIT(CTRL_TRACE, " - mask=0x%X\n", mask);
+	return mask;
+}
 
 /*********************** FILESYSTEM CALLBACKS ***********************/
 /*
@@ -460,93 +452,90 @@ irnet_ctrl_poll(irnet_socket *	ap,
  * Open : when somebody open /dev/irnet
  * We basically create a new instance of irnet and initialise it.
  */
-static int
-dev_irnet_open(struct inode *	inode,
-	       struct file *	file)
+static int dev_irnet_open(struct inode *inode, struct file *file)
 {
-  struct irnet_socket *	ap;
-  int			err;
+	struct irnet_socket *ap;
+	int err;
 
-  DENTER(FS_TRACE, "(file=0x%p)\n", file);
+	DENTER(FS_TRACE, "(file=0x%p)\n", file);
 
 #ifdef SECURE_DEVIRNET
-  /* This could (should?) be enforced by the permissions on /dev/irnet. */
-  if(!capable(CAP_NET_ADMIN))
-    return -EPERM;
-#endif /* SECURE_DEVIRNET */
-
-  /* Allocate a private structure for this IrNET instance */
-  ap = kzalloc(sizeof(*ap), GFP_KERNEL);
-  DABORT(ap == NULL, -ENOMEM, FS_ERROR, "Can't allocate struct irnet...\n");
-
-  /* initialize the irnet structure */
-  ap->file = file;
-
-  /* PPP channel setup */
-  ap->ppp_open = 0;
-  ap->chan.private = ap;
-  ap->chan.ops = &irnet_ppp_ops;
-  ap->chan.mtu = (2048 - TTP_MAX_HEADER - 2 - PPP_HDRLEN);
-  ap->chan.hdrlen = 2 + TTP_MAX_HEADER;		/* for A/C + Max IrDA hdr */
-  /* PPP parameters */
-  ap->mru = (2048 - TTP_MAX_HEADER - 2 - PPP_HDRLEN);
-  ap->xaccm[0] = ~0U;
-  ap->xaccm[3] = 0x60000000U;
-  ap->raccm = ~0U;
-
-  /* Setup the IrDA part... */
-  err = irda_irnet_create(ap);
-  if(err)
-    {
-      DERROR(FS_ERROR, "Can't setup IrDA link...\n");
-      kfree(ap);
-      return err;
-    }
-
-  /* For the control channel */
-  ap->event_index = irnet_events.index;	/* Cancel all past events */
-
-  /* Put our stuff where we will be able to find it later */
-  file->private_data = ap;
-
-  DEXIT(FS_TRACE, " - ap=0x%p\n", ap);
-  return 0;
-}
+	/*
+	 * This could (should?) be enforced by
+	 * the permissions on /dev/irnet.
+	 */
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+#endif				/* SECURE_DEVIRNET */
+
+	/* Allocate a private structure for this IrNET instance */
+	ap = kzalloc(sizeof(*ap), GFP_KERNEL);
+	DABORT(ap == NULL, -ENOMEM, FS_ERROR,
+	       "Can't allocate struct irnet...\n");
+
+	/* initialize the irnet structure */
+	ap->file = file;
+
+	/* PPP channel setup */
+	ap->ppp_open = 0;
+	ap->chan.private = ap;
+	ap->chan.ops = &irnet_ppp_ops;
+	ap->chan.mtu = (2048 - TTP_MAX_HEADER - 2 - PPP_HDRLEN);
+	ap->chan.hdrlen = 2 + TTP_MAX_HEADER;	/* for A/C + Max IrDA hdr */
+	/* PPP parameters */
+	ap->mru = (2048 - TTP_MAX_HEADER - 2 - PPP_HDRLEN);
+	ap->xaccm[0] = ~0U;
+	ap->xaccm[3] = 0x60000000U;
+	ap->raccm = ~0U;
+
+	/* Setup the IrDA part... */
+	err = irda_irnet_create(ap);
+	if (err) {
+		DERROR(FS_ERROR, "Can't setup IrDA link...\n");
+		kfree(ap);
+		return err;
+	}
+
+	/* For the control channel */
+	ap->event_index = irnet_events.index;	/* Cancel all past events */
 
+	/* Put our stuff where we will be able to find it later */
+	file->private_data = ap;
+
+	DEXIT(FS_TRACE, " - ap=0x%p\n", ap);
+	return 0;
+}
 
 /*------------------------------------------------------------------*/
 /*
  * Close : when somebody close /dev/irnet
  * Destroy the instance of /dev/irnet
  */
-static int
-dev_irnet_close(struct inode *	inode,
-		struct file *	file)
+static int dev_irnet_close(struct inode *inode, struct file *file)
 {
-  irnet_socket *	ap = (struct irnet_socket *) file->private_data;
+	irnet_socket *ap = (struct irnet_socket *)file->private_data;
 
-  DENTER(FS_TRACE, "(file=0x%p, ap=0x%p)\n",
-	 file, ap);
-  DABORT(ap == NULL, 0, FS_ERROR, "ap is NULL !!!\n");
+	DENTER(FS_TRACE, "(file=0x%p, ap=0x%p)\n", file, ap);
+	DABORT(ap == NULL, 0, FS_ERROR, "ap is NULL !!!\n");
 
-  /* Detach ourselves */
-  file->private_data = NULL;
+	/* Detach ourselves */
+	file->private_data = NULL;
 
-  /* Close IrDA stuff */
-  irda_irnet_destroy(ap);
+	/* Close IrDA stuff */
+	irda_irnet_destroy(ap);
 
-  /* Disconnect from the generic PPP layer if not already done */
-  if(ap->ppp_open)
-    {
-      DERROR(FS_ERROR, "Channel still registered - deregistering !\n");
-      ap->ppp_open = 0;
-      ppp_unregister_channel(&ap->chan);
-    }
+	/* Disconnect from the generic PPP layer if not already done */
+	if (ap->ppp_open) {
+		DERROR(FS_ERROR,
+		       "Channel still registered - deregistering !\n");
+		ap->ppp_open = 0;
+		ppp_unregister_channel(&ap->chan);
+	}
 
-  kfree(ap);
+	kfree(ap);
 
-  DEXIT(FS_TRACE, "\n");
-  return 0;
+	DEXIT(FS_TRACE, "\n");
+	return 0;
 }
 
 /*------------------------------------------------------------------*/
@@ -555,22 +544,19 @@ dev_irnet_close(struct inode *	inode,
  * (we receive packet from ppp_generic through ppp_irnet_send())
  */
 static ssize_t
-dev_irnet_write(struct file *	file,
-		const char __user *buf,
-		size_t		count,
-		loff_t *	ppos)
+dev_irnet_write(struct file *file,
+		const char __user * buf, size_t count, loff_t * ppos)
 {
-  irnet_socket *	ap = (struct irnet_socket *) file->private_data;
+	irnet_socket *ap = (struct irnet_socket *)file->private_data;
 
-  DPASS(FS_TRACE, "(file=0x%p, ap=0x%p, count=%Zd)\n",
-	file, ap, count);
-  DABORT(ap == NULL, -ENXIO, FS_ERROR, "ap is NULL !!!\n");
+	DPASS(FS_TRACE, "(file=0x%p, ap=0x%p, count=%Zd)\n", file, ap, count);
+	DABORT(ap == NULL, -ENXIO, FS_ERROR, "ap is NULL !!!\n");
 
-  /* If we are connected to ppp_generic, let it handle the job */
-  if(ap->ppp_open)
-    return -EAGAIN;
-  else
-    return irnet_ctrl_write(ap, buf, count);
+	/* If we are connected to ppp_generic, let it handle the job */
+	if (ap->ppp_open)
+		return -EAGAIN;
+	else
+		return irnet_ctrl_write(ap, buf, count);
 }
 
 /*------------------------------------------------------------------*/
@@ -579,47 +565,41 @@ dev_irnet_write(struct file *	file,
  * (pppd poll us, but ultimately reads through /dev/ppp)
  */
 static ssize_t
-dev_irnet_read(struct file *	file,
-	       char __user *	buf,
-	       size_t		count,
-	       loff_t *		ppos)
+dev_irnet_read(struct file *file,
+	       char __user * buf, size_t count, loff_t * ppos)
 {
-  irnet_socket *	ap = (struct irnet_socket *) file->private_data;
+	irnet_socket *ap = (struct irnet_socket *)file->private_data;
 
-  DPASS(FS_TRACE, "(file=0x%p, ap=0x%p, count=%Zd)\n",
-	file, ap, count);
-  DABORT(ap == NULL, -ENXIO, FS_ERROR, "ap is NULL !!!\n");
+	DPASS(FS_TRACE, "(file=0x%p, ap=0x%p, count=%Zd)\n", file, ap, count);
+	DABORT(ap == NULL, -ENXIO, FS_ERROR, "ap is NULL !!!\n");
 
-  /* If we are connected to ppp_generic, let it handle the job */
-  if(ap->ppp_open)
-    return -EAGAIN;
-  else
-    return irnet_ctrl_read(ap, file, buf, count);
+	/* If we are connected to ppp_generic, let it handle the job */
+	if (ap->ppp_open)
+		return -EAGAIN;
+	else
+		return irnet_ctrl_read(ap, file, buf, count);
 }
 
 /*------------------------------------------------------------------*/
 /*
  * Poll : called when someone do a select on /dev/irnet
  */
-static unsigned int
-dev_irnet_poll(struct file *	file,
-	       poll_table *	wait)
+static unsigned int dev_irnet_poll(struct file *file, poll_table * wait)
 {
-  irnet_socket *	ap = (struct irnet_socket *) file->private_data;
-  unsigned int		mask;
+	irnet_socket *ap = (struct irnet_socket *)file->private_data;
+	unsigned int mask;
 
-  DENTER(FS_TRACE, "(file=0x%p, ap=0x%p)\n",
-	 file, ap);
+	DENTER(FS_TRACE, "(file=0x%p, ap=0x%p)\n", file, ap);
 
-  mask = POLLOUT | POLLWRNORM;
-  DABORT(ap == NULL, mask, FS_ERROR, "ap is NULL !!!\n");
+	mask = POLLOUT | POLLWRNORM;
+	DABORT(ap == NULL, mask, FS_ERROR, "ap is NULL !!!\n");
 
-  /* If we are connected to ppp_generic, let it handle the job */
-  if(!ap->ppp_open)
-    mask |= irnet_ctrl_poll(ap, file, wait);
+	/* If we are connected to ppp_generic, let it handle the job */
+	if (!ap->ppp_open)
+		mask |= irnet_ctrl_poll(ap, file, wait);
 
-  DEXIT(FS_TRACE, " - mask=0x%X\n", mask);
-  return(mask);
+	DEXIT(FS_TRACE, " - mask=0x%X\n", mask);
+	return (mask);
 }
 
 /*------------------------------------------------------------------*/
@@ -629,160 +609,158 @@ dev_irnet_poll(struct file *	file,
  * instance is active.
  */
 static int
-dev_irnet_ioctl(struct inode *	inode,
-		struct file *	file,
-		unsigned int	cmd,
-		unsigned long	arg)
+dev_irnet_ioctl(struct inode *inode,
+		struct file *file, unsigned int cmd, unsigned long arg)
 {
-  irnet_socket *	ap = (struct irnet_socket *) file->private_data;
-  int			err;
-  int			val;
-  void __user *argp = (void __user *)arg;
+	irnet_socket *ap = (struct irnet_socket *)file->private_data;
+	int err;
+	int val;
+	void __user *argp = (void __user *)arg;
 
-  DENTER(FS_TRACE, "(file=0x%p, ap=0x%p, cmd=0x%X)\n",
-	 file, ap, cmd);
+	DENTER(FS_TRACE, "(file=0x%p, ap=0x%p, cmd=0x%X)\n", file, ap, cmd);
 
-  /* Basic checks... */
-  DASSERT(ap != NULL, -ENXIO, PPP_ERROR, "ap is NULL...\n");
+	/* Basic checks... */
+	DASSERT(ap != NULL, -ENXIO, PPP_ERROR, "ap is NULL...\n");
 #ifdef SECURE_DEVIRNET
-  if(!capable(CAP_NET_ADMIN))
-    return -EPERM;
-#endif /* SECURE_DEVIRNET */
-
-  err = -EFAULT;
-  switch(cmd)
-    {
-      /* Set discipline (should be N_SYNC_PPP or N_TTY) */
-    case TIOCSETD:
-      if(get_user(val, (int __user *)argp))
-	break;
-      if((val == N_SYNC_PPP) || (val == N_PPP))
-	{
-	  DEBUG(FS_INFO, "Entering PPP discipline.\n");
-	  /* PPP channel setup (ap->chan in configued in dev_irnet_open())*/
-	  err = ppp_register_channel(&ap->chan);
-	  if(err == 0)
-	    {
-	      /* Our ppp side is active */
-	      ap->ppp_open = 1;
-
-	      DEBUG(FS_INFO, "Trying to establish a connection.\n");
-	      /* Setup the IrDA link now - may fail... */
-	      irda_irnet_connect(ap);
-	    }
-	  else
-	    DERROR(FS_ERROR, "Can't setup PPP channel...\n");
-	}
-      else
-	{
-	  /* In theory, should be N_TTY */
-	  DEBUG(FS_INFO, "Exiting PPP discipline.\n");
-	  /* Disconnect from the generic PPP layer */
-	  if(ap->ppp_open)
-	    {
-	      ap->ppp_open = 0;
-	      ppp_unregister_channel(&ap->chan);
-	    }
-	  else
-	    DERROR(FS_ERROR, "Channel not registered !\n");
-	  err = 0;
-	}
-      break;
-
-      /* Query PPP channel and unit number */
-    case PPPIOCGCHAN:
-      if(!ap->ppp_open)
-	break;
-      if(put_user(ppp_channel_index(&ap->chan), (int __user *)argp))
-	break;
-      DEBUG(FS_INFO, "Query channel.\n");
-      err = 0;
-      break;
-    case PPPIOCGUNIT:
-      if(!ap->ppp_open)
-	break;
-      if(put_user(ppp_unit_number(&ap->chan), (int __user *)argp))
-	break;
-      DEBUG(FS_INFO, "Query unit number.\n");
-      err = 0;
-      break;
-
-      /* All these ioctls can be passed both directly and from ppp_generic,
-       * so we just deal with them in one place...
-       */
-    case PPPIOCGFLAGS:
-    case PPPIOCSFLAGS:
-    case PPPIOCGASYNCMAP:
-    case PPPIOCSASYNCMAP:
-    case PPPIOCGRASYNCMAP:
-    case PPPIOCSRASYNCMAP:
-    case PPPIOCGXASYNCMAP:
-    case PPPIOCSXASYNCMAP:
-    case PPPIOCGMRU:
-    case PPPIOCSMRU:
-      DEBUG(FS_INFO, "Standard PPP ioctl.\n");
-      if(!capable(CAP_NET_ADMIN))
-	err = -EPERM;
-      else
-	err = ppp_irnet_ioctl(&ap->chan, cmd, arg);
-      break;
-
-      /* TTY IOCTLs : Pretend that we are a tty, to keep pppd happy */
-      /* Get termios */
-    case TCGETS:
-      DEBUG(FS_INFO, "Get termios.\n");
-      if(kernel_termios_to_user_termios((struct termios __user *)argp, &ap->termios))
-	break;
-      err = 0;
-      break;
-      /* Set termios */
-    case TCSETSF:
-      DEBUG(FS_INFO, "Set termios.\n");
-      if(user_termios_to_kernel_termios(&ap->termios, (struct termios __user *)argp))
-	break;
-      err = 0;
-      break;
-
-      /* Set DTR/RTS */
-    case TIOCMBIS:
-    case TIOCMBIC:
-      /* Set exclusive/non-exclusive mode */
-    case TIOCEXCL:
-    case TIOCNXCL:
-      DEBUG(FS_INFO, "TTY compatibility.\n");
-      err = 0;
-      break;
-
-    case TCGETA:
-      DEBUG(FS_INFO, "TCGETA\n");
-      break;
-
-    case TCFLSH:
-      DEBUG(FS_INFO, "TCFLSH\n");
-      /* Note : this will flush buffers in PPP, so it *must* be done
-       * We should also worry that we don't accept junk here and that
-       * we get rid of our own buffers */
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+#endif				/* SECURE_DEVIRNET */
+
+	err = -EFAULT;
+	switch (cmd) {
+		/* Set discipline (should be N_SYNC_PPP or N_TTY) */
+	case TIOCSETD:
+		if (get_user(val, (int __user *)argp))
+			break;
+		if ((val == N_SYNC_PPP) || (val == N_PPP)) {
+			DEBUG(FS_INFO, "Entering PPP discipline.\n");
+			/*
+			 * PPP channel setup (ap->chan in configued
+			 * in dev_irnet_open())
+			 */
+			err = ppp_register_channel(&ap->chan);
+			if (err == 0) {
+				/* Our ppp side is active */
+				ap->ppp_open = 1;
+
+				DEBUG(FS_INFO,
+				      "Trying to establish a connection.\n");
+				/* Setup the IrDA link now - may fail... */
+				irda_irnet_connect(ap);
+			} else
+				DERROR(FS_ERROR,
+				       "Can't setup PPP channel...\n");
+		} else {
+			/* In theory, should be N_TTY */
+			DEBUG(FS_INFO, "Exiting PPP discipline.\n");
+			/* Disconnect from the generic PPP layer */
+			if (ap->ppp_open) {
+				ap->ppp_open = 0;
+				ppp_unregister_channel(&ap->chan);
+			} else
+				DERROR(FS_ERROR, "Channel not registered !\n");
+			err = 0;
+		}
+		break;
+
+		/* Query PPP channel and unit number */
+	case PPPIOCGCHAN:
+		if (!ap->ppp_open)
+			break;
+		if (put_user(ppp_channel_index(&ap->chan), (int __user *)argp))
+			break;
+		DEBUG(FS_INFO, "Query channel.\n");
+		err = 0;
+		break;
+	case PPPIOCGUNIT:
+		if (!ap->ppp_open)
+			break;
+		if (put_user(ppp_unit_number(&ap->chan), (int __user *)argp))
+			break;
+		DEBUG(FS_INFO, "Query unit number.\n");
+		err = 0;
+		break;
+
+		/*
+		 * All these ioctls can be passed both directly
+		 * and from ppp_generic, so we just deal with them
+		 * in one place...
+		 */
+	case PPPIOCGFLAGS:
+	case PPPIOCSFLAGS:
+	case PPPIOCGASYNCMAP:
+	case PPPIOCSASYNCMAP:
+	case PPPIOCGRASYNCMAP:
+	case PPPIOCSRASYNCMAP:
+	case PPPIOCGXASYNCMAP:
+	case PPPIOCSXASYNCMAP:
+	case PPPIOCGMRU:
+	case PPPIOCSMRU:
+		DEBUG(FS_INFO, "Standard PPP ioctl.\n");
+		if (!capable(CAP_NET_ADMIN))
+			err = -EPERM;
+		else
+			err = ppp_irnet_ioctl(&ap->chan, cmd, arg);
+		break;
+
+		/* TTY IOCTLs: Pretend that we are a tty, to keep pppd happy */
+		/* Get termios */
+	case TCGETS:
+		DEBUG(FS_INFO, "Get termios.\n");
+		if (kernel_termios_to_user_termios
+		    ((struct termios __user *)argp, &ap->termios))
+			break;
+		err = 0;
+		break;
+		/* Set termios */
+	case TCSETSF:
+		DEBUG(FS_INFO, "Set termios.\n");
+		if (user_termios_to_kernel_termios
+		    (&ap->termios, (struct termios __user *)argp))
+			break;
+		err = 0;
+		break;
+
+		/* Set DTR/RTS */
+	case TIOCMBIS:
+	case TIOCMBIC:
+		/* Set exclusive/non-exclusive mode */
+	case TIOCEXCL:
+	case TIOCNXCL:
+		DEBUG(FS_INFO, "TTY compatibility.\n");
+		err = 0;
+		break;
+
+	case TCGETA:
+		DEBUG(FS_INFO, "TCGETA\n");
+		break;
+
+	case TCFLSH:
+		DEBUG(FS_INFO, "TCFLSH\n");
+		/* Note : this will flush buffers in PPP, so it *must* be done
+		 * We should also worry that we don't accept junk here and that
+		 * we get rid of our own buffers */
 #ifdef FLUSH_TO_PPP
-      ppp_output_wakeup(&ap->chan);
-#endif /* FLUSH_TO_PPP */
-      err = 0;
-      break;
-
-    case FIONREAD:
-      DEBUG(FS_INFO, "FIONREAD\n");
-      val = 0;
-      if(put_user(val, (int __user *)argp))
-	break;
-      err = 0;
-      break;
-
-    default:
-      DERROR(FS_ERROR, "Unsupported ioctl (0x%X)\n", cmd);
-      err = -ENOIOCTLCMD;
-    }
-
-  DEXIT(FS_TRACE, " - err = 0x%X\n", err);
-  return err;
+		ppp_output_wakeup(&ap->chan);
+#endif				/* FLUSH_TO_PPP */
+		err = 0;
+		break;
+
+	case FIONREAD:
+		DEBUG(FS_INFO, "FIONREAD\n");
+		val = 0;
+		if (put_user(val, (int __user *)argp))
+			break;
+		err = 0;
+		break;
+
+	default:
+		DERROR(FS_ERROR, "Unsupported ioctl (0x%X)\n", cmd);
+		err = -ENOIOCTLCMD;
+	}
+
+	DEXIT(FS_TRACE, " - err = 0x%X\n", err);
+	return err;
 }
 
 /************************** PPP CALLBACKS **************************/
@@ -798,66 +776,64 @@ dev_irnet_ioctl(struct inode *	inode,
  * according to flags passed by pppd.
  * This is not a callback, but just a helper function used in ppp_irnet_send()
  */
-static inline struct sk_buff *
-irnet_prepare_skb(irnet_socket *	ap,
-		  struct sk_buff *	skb)
+static inline struct sk_buff *irnet_prepare_skb(irnet_socket * ap,
+						struct sk_buff *skb)
 {
-  unsigned char *	data;
-  int			proto;		/* PPP protocol */
-  int			islcp;		/* Protocol == LCP */
-  int			needaddr;	/* Need PPP address */
+	unsigned char *data;
+	int proto;		/* PPP protocol */
+	int islcp;		/* Protocol == LCP */
+	int needaddr;		/* Need PPP address */
 
-  DENTER(PPP_TRACE, "(ap=0x%p, skb=0x%p)\n",
-	 ap, skb);
+	DENTER(PPP_TRACE, "(ap=0x%p, skb=0x%p)\n", ap, skb);
 
-  /* Extract PPP protocol from the frame */
-  data  = skb->data;
-  proto = (data[0] << 8) + data[1];
+	/* Extract PPP protocol from the frame */
+	data = skb->data;
+	proto = (data[0] << 8) + data[1];
 
-  /* LCP packets with codes between 1 (configure-request)
-   * and 7 (code-reject) must be sent as though no options
-   * have been negotiated. */
-  islcp = (proto == PPP_LCP) && (1 <= data[2]) && (data[2] <= 7);
+	/* LCP packets with codes between 1 (configure-request)
+	 * and 7 (code-reject) must be sent as though no options
+	 * have been negotiated. */
+	islcp = (proto == PPP_LCP) && (1 <= data[2]) && (data[2] <= 7);
 
-  /* compress protocol field if option enabled */
-  if((data[0] == 0) && (ap->flags & SC_COMP_PROT) && (!islcp))
-    skb_pull(skb,1);
+	/* compress protocol field if option enabled */
+	if ((data[0] == 0) && (ap->flags & SC_COMP_PROT) && (!islcp))
+		skb_pull(skb, 1);
 
-  /* Check if we need address/control fields */
-  needaddr = 2*((ap->flags & SC_COMP_AC) == 0 || islcp);
+	/* Check if we need address/control fields */
+	needaddr = 2 * ((ap->flags & SC_COMP_AC) == 0 || islcp);
 
-  /* Is the skb headroom large enough to contain all IrDA-headers? */
-  if((skb_headroom(skb) < (ap->max_header_size + needaddr)) ||
-      (skb_shared(skb)))
-    {
-      struct sk_buff *	new_skb;
+	/* Is the skb headroom large enough to contain all IrDA-headers? */
+	if ((skb_headroom(skb) < (ap->max_header_size + needaddr)) ||
+	    (skb_shared(skb))) {
+		struct sk_buff *new_skb;
 
-      DEBUG(PPP_INFO, "Reallocating skb\n");
+		DEBUG(PPP_INFO, "Reallocating skb\n");
 
-      /* Create a new skb */
-      new_skb = skb_realloc_headroom(skb, ap->max_header_size + needaddr);
+		/* Create a new skb */
+		new_skb =
+		    skb_realloc_headroom(skb, ap->max_header_size + needaddr);
 
-      /* We have to free the original skb anyway */
-      dev_kfree_skb(skb);
+		/* We have to free the original skb anyway */
+		dev_kfree_skb(skb);
 
-      /* Did the realloc succeed ? */
-      DABORT(new_skb == NULL, NULL, PPP_ERROR, "Could not realloc skb\n");
+		/* Did the realloc succeed ? */
+		DABORT(new_skb == NULL, NULL, PPP_ERROR,
+		       "Could not realloc skb\n");
 
-      /* Use the new skb instead */
-      skb = new_skb;
-    }
+		/* Use the new skb instead */
+		skb = new_skb;
+	}
 
-  /* prepend address/control fields if necessary */
-  if(needaddr)
-    {
-      skb_push(skb, 2);
-      skb->data[0] = PPP_ALLSTATIONS;
-      skb->data[1] = PPP_UI;
-    }
+	/* prepend address/control fields if necessary */
+	if (needaddr) {
+		skb_push(skb, 2);
+		skb->data[0] = PPP_ALLSTATIONS;
+		skb->data[1] = PPP_UI;
+	}
 
-  DEXIT(PPP_TRACE, "\n");
+	DEXIT(PPP_TRACE, "\n");
 
-  return skb;
+	return skb;
 }
 
 /*------------------------------------------------------------------*/
@@ -868,100 +844,101 @@ irnet_prepare_skb(irnet_socket *	ap,
  * If the packet was not accepted, we will call ppp_output_wakeup
  * at some later time to reactivate flow control in ppp_generic.
  */
-static int
-ppp_irnet_send(struct ppp_channel *	chan,
-	       struct sk_buff *		skb)
+static int ppp_irnet_send(struct ppp_channel *chan, struct sk_buff *skb)
 {
-  irnet_socket *	self = (struct irnet_socket *) chan->private;
-  int			ret;
+	irnet_socket *self = (struct irnet_socket *)chan->private;
+	int ret;
 
-  DENTER(PPP_TRACE, "(channel=0x%p, ap/self=0x%p)\n",
-	 chan, self);
+	DENTER(PPP_TRACE, "(channel=0x%p, ap/self=0x%p)\n", chan, self);
 
-  /* Check if things are somewhat valid... */
-  DASSERT(self != NULL, 0, PPP_ERROR, "Self is NULL !!!\n");
+	/* Check if things are somewhat valid... */
+	DASSERT(self != NULL, 0, PPP_ERROR, "Self is NULL !!!\n");
 
-  /* Check if we are connected */
-  if(!(test_bit(0, &self->ttp_open)))
-    {
+	/* Check if we are connected */
+	if (!(test_bit(0, &self->ttp_open))) {
 #ifdef CONNECT_IN_SEND
-      /* Let's try to connect one more time... */
-      /* Note : we won't be connected after this call, but we should be
-       * ready for next packet... */
-      /* If we are already connecting, this will fail */
-      irda_irnet_connect(self);
-#endif /* CONNECT_IN_SEND */
-
-      DEBUG(PPP_INFO, "IrTTP not ready ! (%ld-%ld)\n",
-	    self->ttp_open, self->ttp_connect);
-
-      /* Note : we can either drop the packet or block the packet.
-       *
-       * Blocking the packet allow us a better connection time,
-       * because by calling ppp_output_wakeup() we can have
-       * ppp_generic resending the LCP request immediately to us,
-       * rather than waiting for one of pppd periodic transmission of
-       * LCP request.
-       *
-       * On the other hand, if we block all packet, all those periodic
-       * transmissions of pppd accumulate in ppp_generic, creating a
-       * backlog of LCP request. When we eventually connect later on,
-       * we have to transmit all this backlog before we can connect
-       * proper (if we don't timeout before).
-       *
-       * The current strategy is as follow :
-       * While we are attempting to connect, we block packets to get
-       * a better connection time.
-       * If we fail to connect, we drain the queue and start dropping packets
-       */
+		/* Let's try to connect one more time... */
+		/*
+		 * Note : we won't be connected after this call,
+		 * but we should be ready for next packet...
+		 */
+		/* If we are already connecting, this will fail */
+		irda_irnet_connect(self);
+#endif				/* CONNECT_IN_SEND */
+
+		DEBUG(PPP_INFO, "IrTTP not ready ! (%ld-%ld)\n",
+		      self->ttp_open, self->ttp_connect);
+
+		/*
+		 * Note : we can either drop the packet or block the packet.
+		 *
+		 * Blocking the packet allow us a better connection time,
+		 * because by calling ppp_output_wakeup() we can have
+		 * ppp_generic resending the LCP request immediately to us,
+		 * rather than waiting for one of pppd periodic transmission of
+		 * LCP request.
+		 *
+		 * On the other hand, if we block all packet, all those
+		 * periodic transmissions of pppd accumulate in ppp_generic,
+		 * creating a backlog of LCP request. When we eventually
+		 * connect later on, we have to transmit all this backlog
+		 * before we can connect proper (if we don't timeout before).
+		 *
+		 * The current strategy is as follow :
+		 * While we are attempting to connect, we block packets to get
+		 * a better connection time.
+		 * If we fail to connect, we drain the queue and start
+		 * dropping packets
+		 */
 #ifdef BLOCK_WHEN_CONNECT
-      /* If we are attempting to connect */
-      if(test_bit(0, &self->ttp_connect))
-	{
-	  /* Blocking packet, ppp_generic will retry later */
-	  return 0;
+		/* If we are attempting to connect */
+		if (test_bit(0, &self->ttp_connect)) {
+			/* Blocking packet, ppp_generic will retry later */
+			return 0;
+		}
+#endif				/* BLOCK_WHEN_CONNECT */
+
+		/* Dropping packet, pppd will retry later */
+		dev_kfree_skb(skb);
+		return 1;
 	}
-#endif /* BLOCK_WHEN_CONNECT */
-
-      /* Dropping packet, pppd will retry later */
-      dev_kfree_skb(skb);
-      return 1;
-    }
-
-  /* Check if the queue can accept any packet, otherwise block */
-  if(self->tx_flow != FLOW_START)
-    DRETURN(0, PPP_INFO, "IrTTP queue full (%d skbs)...\n",
-	    skb_queue_len(&self->tsap->tx_queue));
-
-  /* Prepare ppp frame for transmission */
-  skb = irnet_prepare_skb(self, skb);
-  DABORT(skb == NULL, 1, PPP_ERROR, "Prepare skb for Tx failed.\n");
-
-  /* Send the packet to IrTTP */
-  ret = irttp_data_request(self->tsap, skb);
-  if(ret < 0)
-    {
-      /*
-       * > IrTTPs tx queue is full, so we just have to
-       * > drop the frame! You might think that we should
-       * > just return -1 and don't deallocate the frame,
-       * > but that is dangerous since it's possible that
-       * > we have replaced the original skb with a new
-       * > one with larger headroom, and that would really
-       * > confuse do_dev_queue_xmit() in dev.c! I have
-       * > tried :-) DB
-       * Correction : we verify the flow control above (self->tx_flow),
-       * so we come here only if IrTTP doesn't like the packet (empty,
-       * too large, IrTTP not connected). In those rare cases, it's ok
-       * to drop it, we don't want to see it here again...
-       * Jean II
-       */
-      DERROR(PPP_ERROR, "IrTTP doesn't like this packet !!! (0x%X)\n", ret);
-      /* irttp_data_request already free the packet */
-    }
-
-  DEXIT(PPP_TRACE, "\n");
-  return 1;	/* Packet has been consumed */
+
+	/* Check if the queue can accept any packet, otherwise block */
+	if (self->tx_flow != FLOW_START)
+		DRETURN(0, PPP_INFO, "IrTTP queue full (%d skbs)...\n",
+			skb_queue_len(&self->tsap->tx_queue));
+
+	/* Prepare ppp frame for transmission */
+	skb = irnet_prepare_skb(self, skb);
+	DABORT(skb == NULL, 1, PPP_ERROR, "Prepare skb for Tx failed.\n");
+
+	/* Send the packet to IrTTP */
+	ret = irttp_data_request(self->tsap, skb);
+	if (ret < 0) {
+		/*
+		 * > IrTTPs tx queue is full, so we just have to
+		 * > drop the frame! You might think that we should
+		 * > just return -1 and don't deallocate the frame,
+		 * > but that is dangerous since it's possible that
+		 * > we have replaced the original skb with a new
+		 * > one with larger headroom, and that would really
+		 * > confuse do_dev_queue_xmit() in dev.c! I have
+		 * > tried :-) DB
+		 * Correction : we verify the flow control above
+		 * (self->tx_flow), so we come here only if IrTTP doesn't like
+		 * the packet (empty, too large, IrTTP not connected).
+		 * In those rare cases, it's ok to drop it, we don't want to
+		 * see it here again...
+		 * Jean II
+		 */
+		DERROR(PPP_ERROR,
+		       "IrTTP doesn't like this packet !!! (0x%X)\n",
+		       ret);
+		/* irttp_data_request already free the packet */
+	}
+
+	DEXIT(PPP_TRACE, "\n");
+	return 1;		/* Packet has been consumed */
 }
 
 /*------------------------------------------------------------------*/
@@ -970,97 +947,94 @@ ppp_irnet_send(struct ppp_channel *	chan,
  * Note : we are also called from dev_irnet_ioctl().
  */
 static int
-ppp_irnet_ioctl(struct ppp_channel *	chan,
-		unsigned int		cmd,
-		unsigned long		arg)
+ppp_irnet_ioctl(struct ppp_channel *chan, unsigned int cmd, unsigned long arg)
 {
-  irnet_socket *	ap = (struct irnet_socket *) chan->private;
-  int			err;
-  int			val;
-  u32			accm[8];
-  void __user *argp = (void __user *)arg;
-
-  DENTER(PPP_TRACE, "(channel=0x%p, ap=0x%p, cmd=0x%X)\n",
-	 chan, ap, cmd);
-
-  /* Basic checks... */
-  DASSERT(ap != NULL, -ENXIO, PPP_ERROR, "ap is NULL...\n");
-
-  err = -EFAULT;
-  switch(cmd)
-    {
-      /* PPP flags */
-    case PPPIOCGFLAGS:
-      val = ap->flags | ap->rbits;
-      if(put_user(val, (int __user *) argp))
-	break;
-      err = 0;
-      break;
-    case PPPIOCSFLAGS:
-      if(get_user(val, (int __user *) argp))
-	break;
-      ap->flags = val & ~SC_RCV_BITS;
-      ap->rbits = val & SC_RCV_BITS;
-      err = 0;
-      break;
-
-      /* Async map stuff - all dummy to please pppd */
-    case PPPIOCGASYNCMAP:
-      if(put_user(ap->xaccm[0], (u32 __user *) argp))
-	break;
-      err = 0;
-      break;
-    case PPPIOCSASYNCMAP:
-      if(get_user(ap->xaccm[0], (u32 __user *) argp))
-	break;
-      err = 0;
-      break;
-    case PPPIOCGRASYNCMAP:
-      if(put_user(ap->raccm, (u32 __user *) argp))
-	break;
-      err = 0;
-      break;
-    case PPPIOCSRASYNCMAP:
-      if(get_user(ap->raccm, (u32 __user *) argp))
-	break;
-      err = 0;
-      break;
-    case PPPIOCGXASYNCMAP:
-      if(copy_to_user(argp, ap->xaccm, sizeof(ap->xaccm)))
-	break;
-      err = 0;
-      break;
-    case PPPIOCSXASYNCMAP:
-      if(copy_from_user(accm, argp, sizeof(accm)))
-	break;
-      accm[2] &= ~0x40000000U;		/* can't escape 0x5e */
-      accm[3] |= 0x60000000U;		/* must escape 0x7d, 0x7e */
-      memcpy(ap->xaccm, accm, sizeof(ap->xaccm));
-      err = 0;
-      break;
-
-      /* Max PPP frame size */
-    case PPPIOCGMRU:
-      if(put_user(ap->mru, (int __user *) argp))
-	break;
-      err = 0;
-      break;
-    case PPPIOCSMRU:
-      if(get_user(val, (int __user *) argp))
-	break;
-      if(val < PPP_MRU)
-	val = PPP_MRU;
-      ap->mru = val;
-      err = 0;
-      break;
-
-    default:
-      DEBUG(PPP_INFO, "Unsupported ioctl (0x%X)\n", cmd);
-      err = -ENOIOCTLCMD;
-    }
-
-  DEXIT(PPP_TRACE, " - err = 0x%X\n", err);
-  return err;
+	irnet_socket *ap = (struct irnet_socket *)chan->private;
+	int err;
+	int val;
+	u32 accm[8];
+	void __user *argp = (void __user *)arg;
+
+	DENTER(PPP_TRACE, "(channel=0x%p, ap=0x%p, cmd=0x%X)\n",
+	       chan, ap, cmd);
+
+	/* Basic checks... */
+	DASSERT(ap != NULL, -ENXIO, PPP_ERROR, "ap is NULL...\n");
+
+	err = -EFAULT;
+	switch (cmd) {
+		/* PPP flags */
+	case PPPIOCGFLAGS:
+		val = ap->flags | ap->rbits;
+		if (put_user(val, (int __user *)argp))
+			break;
+		err = 0;
+		break;
+	case PPPIOCSFLAGS:
+		if (get_user(val, (int __user *)argp))
+			break;
+		ap->flags = val & ~SC_RCV_BITS;
+		ap->rbits = val & SC_RCV_BITS;
+		err = 0;
+		break;
+
+		/* Async map stuff - all dummy to please pppd */
+	case PPPIOCGASYNCMAP:
+		if (put_user(ap->xaccm[0], (u32 __user *) argp))
+			break;
+		err = 0;
+		break;
+	case PPPIOCSASYNCMAP:
+		if (get_user(ap->xaccm[0], (u32 __user *) argp))
+			break;
+		err = 0;
+		break;
+	case PPPIOCGRASYNCMAP:
+		if (put_user(ap->raccm, (u32 __user *) argp))
+			break;
+		err = 0;
+		break;
+	case PPPIOCSRASYNCMAP:
+		if (get_user(ap->raccm, (u32 __user *) argp))
+			break;
+		err = 0;
+		break;
+	case PPPIOCGXASYNCMAP:
+		if (copy_to_user(argp, ap->xaccm, sizeof(ap->xaccm)))
+			break;
+		err = 0;
+		break;
+	case PPPIOCSXASYNCMAP:
+		if (copy_from_user(accm, argp, sizeof(accm)))
+			break;
+		accm[2] &= ~0x40000000U;	/* can't escape 0x5e */
+		accm[3] |= 0x60000000U;	/* must escape 0x7d, 0x7e */
+		memcpy(ap->xaccm, accm, sizeof(ap->xaccm));
+		err = 0;
+		break;
+
+		/* Max PPP frame size */
+	case PPPIOCGMRU:
+		if (put_user(ap->mru, (int __user *)argp))
+			break;
+		err = 0;
+		break;
+	case PPPIOCSMRU:
+		if (get_user(val, (int __user *)argp))
+			break;
+		if (val < PPP_MRU)
+			val = PPP_MRU;
+		ap->mru = val;
+		err = 0;
+		break;
+
+	default:
+		DEBUG(PPP_INFO, "Unsupported ioctl (0x%X)\n", cmd);
+		err = -ENOIOCTLCMD;
+	}
+
+	DEXIT(PPP_TRACE, " - err = 0x%X\n", err);
+	return err;
 }
 
 /************************** INITIALISATION **************************/
@@ -1073,60 +1047,56 @@ ppp_irnet_ioctl(struct ppp_channel *	chan,
  * Hook our device callbacks in the filesystem, to connect our code
  * to /dev/irnet
  */
-static inline int __init
-ppp_irnet_init(void)
+static inline int __init ppp_irnet_init(void)
 {
-  int err = 0;
+	int err = 0;
 
-  DENTER(MODULE_TRACE, "()\n");
+	DENTER(MODULE_TRACE, "()\n");
 
-  /* Allocate ourselves as a minor in the misc range */
-  err = misc_register(&irnet_misc_device);
+	/* Allocate ourselves as a minor in the misc range */
+	err = misc_register(&irnet_misc_device);
 
-  DEXIT(MODULE_TRACE, "\n");
-  return err;
+	DEXIT(MODULE_TRACE, "\n");
+	return err;
 }
 
 /*------------------------------------------------------------------*/
 /*
  * Cleanup at exit...
  */
-static inline void __exit
-ppp_irnet_cleanup(void)
+static inline void __exit ppp_irnet_cleanup(void)
 {
-  DENTER(MODULE_TRACE, "()\n");
+	DENTER(MODULE_TRACE, "()\n");
 
-  /* De-allocate /dev/irnet minor in misc range */
-  misc_deregister(&irnet_misc_device);
+	/* De-allocate /dev/irnet minor in misc range */
+	misc_deregister(&irnet_misc_device);
 
-  DEXIT(MODULE_TRACE, "\n");
+	DEXIT(MODULE_TRACE, "\n");
 }
 
 /*------------------------------------------------------------------*/
 /*
  * Module main entry point
  */
-static int __init
-irnet_init(void)
+static int __init irnet_init(void)
 {
-  int err;
+	int err;
 
-  /* Initialise both parts... */
-  err = irda_irnet_init();
-  if(!err)
-    err = ppp_irnet_init();
-  return err;
+	/* Initialise both parts... */
+	err = irda_irnet_init();
+	if (!err)
+		err = ppp_irnet_init();
+	return err;
 }
 
 /*------------------------------------------------------------------*/
 /*
  * Module exit
  */
-static void __exit
-irnet_cleanup(void)
+static void __exit irnet_cleanup(void)
 {
-  irda_irnet_cleanup();
-  ppp_irnet_cleanup();
+	irda_irnet_cleanup();
+	ppp_irnet_cleanup();
 }
 
 /*------------------------------------------------------------------*/
diff --git a/net/irda/irnet/irnet_ppp.h b/net/irda/irnet/irnet_ppp.h
index d2beb7d..0c85dfb 100644
--- a/net/irda/irnet/irnet_ppp.h
+++ b/net/irda/irnet/irnet_ppp.h
@@ -41,79 +41,55 @@
 
 /****************************** TYPES ******************************/
 
-
 /**************************** PROTOTYPES ****************************/
 
 /* ----------------------- CONTROL CHANNEL ----------------------- */
+static inline ssize_t irnet_ctrl_write(irnet_socket *, const char *, size_t);
 static inline ssize_t
-	irnet_ctrl_write(irnet_socket *,
-			 const char *,
-			 size_t);
-static inline ssize_t
-	irnet_ctrl_read(irnet_socket *,
-			struct file *,
-			char *,
-			size_t);
+irnet_ctrl_read(irnet_socket *, struct file *, char *, size_t);
 static inline unsigned int
-	irnet_ctrl_poll(irnet_socket *,
-			struct file *,
-			poll_table *);
+irnet_ctrl_poll(irnet_socket *, struct file *, poll_table *);
 /* ----------------------- CHARACTER DEVICE ----------------------- */
-static int
-	dev_irnet_open(struct inode *,	/* fs callback : open */
-		       struct file *),
-	dev_irnet_close(struct inode *,
-			struct file *);
+static int dev_irnet_open(struct inode *,	/* fs callback : open */
+			  struct file *),
+dev_irnet_close(struct inode *, struct file *);
 static ssize_t
-	dev_irnet_write(struct file *,
-			const char __user *,
-			size_t,
-			loff_t *),
-	dev_irnet_read(struct file *,
-		       char __user *,
-		       size_t,
-		       loff_t *);
-static unsigned int
-	dev_irnet_poll(struct file *,
-		       poll_table *);
+dev_irnet_write(struct file *,
+		const char __user *,
+		size_t,
+		loff_t *),
+dev_irnet_read(struct file *, char __user *, size_t, loff_t *);
+static unsigned int dev_irnet_poll(struct file *, poll_table *);
 static int
-	dev_irnet_ioctl(struct inode *,
-			struct file *,
-			unsigned int,
-			unsigned long);
+dev_irnet_ioctl(struct inode *, struct file *, unsigned int, unsigned long);
 /* ------------------------ PPP INTERFACE ------------------------ */
-static inline struct sk_buff *
-	irnet_prepare_skb(irnet_socket *,
-			  struct sk_buff *);
-static int
-	ppp_irnet_send(struct ppp_channel *,
-		      struct sk_buff *);
-static int
-	ppp_irnet_ioctl(struct ppp_channel *,
-			unsigned int,
-			unsigned long);
+static inline struct sk_buff *irnet_prepare_skb(irnet_socket *,
+						struct sk_buff *);
+static int ppp_irnet_send(struct ppp_channel *, struct sk_buff *);
+static int ppp_irnet_ioctl(struct ppp_channel *, unsigned int, unsigned long);
 
 /**************************** VARIABLES ****************************/
 
 /* Filesystem callbacks (to call us) */
-static struct file_operations irnet_device_fops =
-{
-	.owner		= THIS_MODULE,
-	.read		= dev_irnet_read,
-	.write		= dev_irnet_write,
-	.poll		= dev_irnet_poll,
-	.ioctl		= dev_irnet_ioctl,
-	.open		= dev_irnet_open,
-	.release	= dev_irnet_close
-  /* Also : llseek, readdir, mmap, flush, fsync, fasync, lock, readv, writev */
+static struct file_operations irnet_device_fops = {
+	.owner = THIS_MODULE,
+	.read = dev_irnet_read,
+	.write = dev_irnet_write,
+	.poll = dev_irnet_poll,
+	.ioctl = dev_irnet_ioctl,
+	.open = dev_irnet_open,
+	.release = dev_irnet_close
+       /*
+	* Also : llseek, readdir, mmap, flush, fsync,
+	* fasync, lock, readv, writev
+	*/
 };
 
 /* Structure so that the misc major (drivers/char/misc.c) take care of us... */
-static struct miscdevice irnet_misc_device =
-{
+static struct miscdevice irnet_misc_device = {
 	IRNET_MINOR,
 	"irnet",
 	&irnet_device_fops
 };
 
-#endif /* IRNET_PPP_H */
+#endif				/* IRNET_PPP_H */
-- 
1.4.4.4


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
