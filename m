From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Sat, 3 Feb 2007 20:43:49 -0200
Message-ID: <20070203224349.GA18418@dmt>
References: <20070116185524.GA5681@dmt> <200701270253.08320.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:60974 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800AbXBCWr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Feb 2007 17:47:29 -0500
Content-Disposition: inline
In-Reply-To: <200701270253.08320.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On Sat, Jan 27, 2007 at 02:53:07AM +0100, Arnd Bergmann wrote:
> On Tuesday 16 January 2007 19:55, Marcelo Tosatti wrote:
> >=20
> > Announcing an updated patch of the Marvell Libertas 8388 802.11 USB
> > driver.
> >=20
> > Diff can be found at=20
> > http://dev.laptop.org/~marcelo/libertas-8388-16012007.patch
> >=20
> > _Please_ review, this driver is targeted for mainline inclusion.
> >=20
> > There have been almost no comments resulting from the first submiss=
ion.
>=20
> I think the main problem is the size of the driver. I have spend seve=
ral
> hours on reviewing it, but this has barely scratched the surface of
> the problems that are still in it. Most of the important problems
> have already been discussed widely, but I'll still post what I notice=
d
> about the driver.

Thanks so much! Really useful. Thats the sort of commentary I was
looking for.

> My general feeling is that even at this point it would be better to
> write a new driver for it from scratch than trying to remove all
> the bloat from the existing one. Of course, that requires deep
> knowledge of how the hardware works, so I don't consider the time
> you spent on hacking it lost.

Well, I think the driver is pretty complete (support for the large
number of parameters the firmware exposes is implemented), and even
though it contains a lot of bloat it is worthwhile to continue the
cleanup process, IMHO.=20

Also, the driver has been pretty well tested already.

> I also think that your work done so far is an enormous improvement
> over where it started, you are definitely on the right track.
>=20
> The level of detail in my review drops towards the end, mostly
> because some issues found in the first files are continuing to
> throughout the driver.
>=20
> > --- /dev/null
> > +++ b/drivers/net/wireless/libertas/Makefile
> > @@ -0,0 +1,21 @@
> > +# EXTRA_CFLAGS +=3D -Wpacked
> > +
> > +usb8xxx-objs :=3D wlan_main.o wlan_fw.o wlan_wext.o \
> > +		wlan_rx.o wlan_tx.o wlan_cmd.o 	  \
> > +		wlan_cmdresp.o wlan_scan.o	  \
> > +		wlan_join.o wlan_11d.o 		  \
> > +		wlan_ioctl.o wlan_debugfs.o	  \
> > +		wlan_ethtool.o wlan_assoc.o
> > +
>=20
> I guess you can get rid of the wlan_ file name prefix, since all file=
s
> are already in the same directory to give them  a name space.

Done.

> > +
> > + (c) Copyright  2003-2006, Marvell International Ltd.=20
> > + All Rights Reserved
> > +
>=20
> 'All Rights Reserved' sounds wrong, considering it's actually GPL.

A bunch of other drivers also have "All Rights Reserved" for the compan=
y
or individual who wrote the driver. I don't see it as a problem,
considering its GPL anyway.

> > +  * This file contains definitions of WLAN commands.
> > +  * =20
> > +  * (c) Copyright =C2=A9 2003-2006, Marvell International Ltd.=20
>=20
> Something went wrong with the (c) character here, better not use UTF8
> characters in source.

Done.

> > +Change log:
> > +    10/11/05: Add Doxygen format comments
> > +    01/11/06: Remove assoc response codes; full IEEE assoc resp no=
w returned
> > +    04/06/06: Add TSPEC, queue metrics, and MSDU expiry support
> > +    04/10/06: Add power_adapt_cfg_ext command
> > +    04/18/06: Remove old Subscrive Event and add new Subscribe Eve=
nt
> > +	      implementation through generic hostcmd API
>=20
> changelog should go away

Done.

> > +/** Command Processing States and Options */
> > +#define HostCmd_STATE_IDLE                    0x0000
> > +#define HostCmd_STATE_IN_USE_BY_HOST          0x0001
> > +#define HostCmd_STATE_IN_USE_BY_MINIPORT      0x0002
> > +#define HostCmd_STATE_FINISHED                0x000f
>=20
> No SilLYcAps please
>=20
> > +
> > +/** General Result Code*/
> > +/* OK */
> > +#define HostCmd_RESULT_OK                    0x0000
> > +/* Genenral error */
> > +#define HostCmd_RESULT_ERROR                 0x0001
> > +/* Command is not valid */
> > +#define HostCmd_RESULT_NOT_SUPPORT           0x0002
> > +/* Command is pending */
> > +#define HostCmd_RESULT_PENDING               0x0003
> > +/* System is busy (command ignored) */
> > +#define HostCmd_RESULT_BUSY                  0x0004
> > +/* Data buffer is not big enough */
> > +#define HostCmd_RESULT_PARTIAL_DATA          0x0005
>=20
> These seem to be completely unused, except HostCmd_RESULT_OK, which
> you can then remove as well.

Done.

> > +/* Definition of action or option for each command */
> > +
> > +/* Define general purpose action */
> > +#define HostCmd_ACT_GEN_READ                    0x0000
> > +#define HostCmd_ACT_GEN_WRITE                   0x0001
> > +#define HostCmd_ACT_GEN_GET                     0x0000
> > +#define HostCmd_ACT_GEN_SET                     0x0001
> > +#define HostCmd_ACT_GEN_REMOVE			0x0002
> > +#define HostCmd_ACT_GEN_OFF                     0x0000
> > +#define HostCmd_ACT_GEN_ON                      0x0001
> > +
> > +/* Define action or option for HostCmd_CMD_802_11_AUTHENTICATE */
> > +#define HostCmd_ACT_AUTHENTICATE                0x0001
> > +#define HostCmd_ACT_DEAUTHENTICATE              0x0002
> > +
> > +/* Define action or option for HostCmd_CMD_802_11_ASSOCIATE */
> > +#define HostCmd_ACT_ASSOCIATE                   0x0001
> > +#define HostCmd_ACT_DISASSOCIATE                0x0002
> > +#define HostCmd_ACT_REASSOCIATE                 0x0003
> > +
> > +#define HostCmd_CAPINFO_ESS                     0x0001
> > +#define HostCmd_CAPINFO_IBSS                    0x0002
> > +#define HostCmd_CAPINFO_CF_POLLABLE             0x0004
> > +#define HostCmd_CAPINFO_CF_REQUEST              0x0008
> > +#define HostCmd_CAPINFO_PRIVACY                 0x0010
>=20
> Most of these are unused as well, I guess it would be good
> to go through the whole list and see what can be removed.

Done. Will go through the entire file list before posting the next
patch.

> > +/* TxPD descriptor */
> > +struct TxPD {
> > +	/* Current Tx packet status */
> > +	u32 TxStatus;
> > +	/* Tx Control */
> > +	u32 TxControl;
> > +	u32 TxPacketLocation;
> > +	/* Tx packet length */
> > +	u16 TxPacketLength;
> > +	/* First 2 byte of destination MAC address */
> > +	u8 TxDestAddrHigh[2];
> > +	/* Last 4 byte of destination MAC address */
> > +	u8 TxDestAddrLow[4];
> > +	/* Pkt Priority */
> > +	u8 Priority;
> > +	/* Pkt Trasnit Power control */
> > +	u8 PowerMgmt;
> > +	/* Amount of time the packet has been queued in the driver (units=
 =3D 2ms) */
> > +	u8 PktDelay_2ms;
> > +	/* Reserved */
> > +	u8 Reserved1;
> > +};
>=20
> More SilLYcAps to convert...

I've started conversion to normalcaps, have to finish it...

> > +struct WLAN_802_11_KEY {
> > +	u16 type; /* KEY_TYPE_* from wlan_defs.h */
> > +	u32 len;
> > +	u8 key[MRVL_MAX_KEY_WPA_KEY_LENGTH];
> > +	u32 flags;  /* KEY_INFO_* from wlan_defs.h */
> > +};
> > +
>=20
> This structure has member misalignment which requires
> padding. If you use them only in the kernel, please reorder the
> members to avoid this, otherwise it's probably better to
> make the padding explicit.

The former, reordered.

> > +/* HostCmd_DS_GET_HW_SPEC */
> > +struct HostCmd_DS_GET_HW_SPEC {
> > +	/* HW Interface version number */
> > +	u16 HWIfVersion;
> > +
> > +	/* HW version number */
> > +	u16 Version;
> > +
> > +	/* Max number of TxPD FW can handle */
> > +	u16 NumOfTxPD;
> > +
> > +	/* Max no of Multicast address */
> > +	u16 NumOfMCastAdr;
> > +
> > +	/* MAC address */
> > +	u8 PermanentAddr[6];
> > +
> > +	/* Region Code */
> > +	u16 RegionCode;
> > +
> > +	/* Number of antenna used */
> > +	u16 NumberOfAntenna;
> > +
> > +	/* FW release number, example 0x1234=3D1.2.3.4 */
> > +	u32 FWReleaseNumber;
> > +
> > +	/* Base Address of TxPD queue */
> > +	u32 WcbBase;
> > +	/* Read Pointer of RxPd queue */
> > +	u32 RxPdRdPtr;
> > +
> > +	/* Write Pointer of RxPd queue */
> > +	u32 RxPdWrPtr;
> > +
> > +	/*FW/HW Capability */
> > +	u32 fwCapInfo;
> > +} __attribute__ ((packed));
> > +
> > +/* HostCmd_CMD_EEPROM_UPDATE */
> > +struct HostCmd_DS_EEPROM_UPDATE {
> > +	u16 Action;
> > +	u32 Value;
> > +} __attribute__ ((packed));
> > +
>=20
> Why do you want to have these structures packed? This often causes
> much worse code than reordering the members for proper alignment.

The command structures are defined and interpreted by the firmware (ie
used by hardware), and as such should be packed (to avoid padding) and
can't be reordered.

> > +/* HostCmd_RET_802_11_ASSOCIATE */
> > +struct HostCmd_DS_802_11_ASSOCIATE_RSP {
> > +	struct IEEEtypes_AssocRsp assocRsp;
> > +} __attribute__ ((packed));
>=20
> this ((packed)) looks really weird, are you sure it does what you
> want it to?

This one is indeed not necessary, since "struct IEEEtypes_AssocRsp" is
attributed as packed.

> > +/* HostCmd_DS_802_11_AFC */
> > +struct HostCmd_DS_802_11_AFC {
> > +	u16 afc_auto;
> > +	union {
> > +		struct {
> > +			u16 threshold;
> > +			u16 period;
> > +		} auto_mode;
> > +		struct {
> > +			s16 timing_offset;
> > +			s16 carrier_offset;
> > +		} manual_mode;
> > +	} b;
> > +} __attribute__ ((packed));
> > +
> > +#define afc_data b.data
> > +#define afc_thre b.auto_mode.threshold
> > +#define afc_period b.auto_mode.period
> > +#define afc_toff b.manual_mode.timing_offset
> > +#define afc_foff b.manual_mode.carrier_offset
>=20
> should we use anonymous unions here? all recent gcc versions
> allow it.

Done. Also anonymize "manual_mode"/"auto_mode" structures.

> > +		struct HostCmd_TX_RATE_QUERY txrate;
> > +		struct HostCmd_DS_BT_ACCESS bt;
> > +		struct HostCmd_DS_FWT_ACCESS fwt;
> > +		struct HostCmd_DS_MESH_ACCESS mesh;
> > +		struct HostCmd_DS_GET_TSF gettsf;
> > +		struct HostCmd_DS_802_11_SUBSCRIBE_EVENT subscribe_event;
> > +	} params;
> > +} __attribute__ ((packed));
>=20
> same here.

Can't do:=20

int libertas_ret_80211_associate(wlan_private * priv,
                  struct HostCmd_DS_COMMAND *resp)
{
    wlan_adapter *Adapter =3D priv->adapter;
    int ret =3D 0;
    union iwreq_data wrqu;
    struct IEEEtypes_AssocRsp *pAssocRsp;
    struct bss_descriptor *pBSSDesc;

    ENTER();

    pAssocRsp =3D (struct IEEEtypes_AssocRsp *) & resp->params;

> > +
> > +extern struct BootCMDStr	sBootCMD;
> > +
>=20
> 'extern' declarations should _all_ go into header files. Normally,
> sparse should catch this.=20

Done.

> Did you run the file through a recent sparse successfully?

Spits a bunch of warnings, looking at them.

> > +int if_usb_issue_boot_command(wlan_private *priv, int iValue)
> > +{
> > +	struct usb_card_rec	*cardp =3D priv->wlan_dev.card;
> > +	int i;
> > +
> > +	/* Prepare Command */
> > +	sBootCMD.u32MagicNumber =3D BOOT_CMD_MAGIC_NUMBER;
> > +	sBootCMD.u8CMD_Tag =3D iValue;
> > +	for (i=3D0; i<11; i++)
> > +		sBootCMD.au8Dumy[i]=3D0x00;
> > +	memcpy(cardp->bulk_out_buffer, &sBootCMD, sizeof(struct BootCMDSt=
r));
>=20
> It looks like a bad idea to use the global sBootCMD variable here. I
> can't see any locking to protect it, and it's small enough to fit on =
the
> stack. What's the point?

No point, moved to if_usb_issue_boot_command's stack.

> > +
> > +	/* Issue Command */
> > +	usb_tx_block(priv, cardp->bulk_out_buffer, sizeof(struct BootCMDS=
tr));
> > +
> > +	return WLAN_STATUS_SUCCESS;
> > +}
>=20
> WLAN_STATUS_SUCCESS is not a standard return code. It would be better=
 to
> use the standard calling conventions returning '0' or '-ESOMETHING'
> for failure instead of defining your own.

Done.

> > +static usb_notifier_fn_add wlan_card_add_cb =3D NULL;
> > +static usb_notifier_fn_remove wlan_card_remove_cb =3D NULL;
>=20
> You currently link the usb parts and the wlan parts of the driver
> into a single module, which makes the dynamic registration of these
> callbacks rather pointless. Can't you just get rid of that entirely?

Done.

> > +static u8 usb_int_cause =3D 0;
>=20
> This is a global variable, but you seem to use it per device. Is that
> intended?

No, its a bug. Fixed.

> > +struct BootCMDStr       sBootCMD;
>=20
> This variable is used only in one file, but defined in another...

=46ixed.

> > +int if_usb_issue_boot_command(wlan_private *priv, int iValue);
> > +
> > +static int if_prog_firmware(wlan_private * priv);
> > +static void if_usb_receive(struct urb *urb);
> > +static void if_usb_receive_fwload(struct urb *urb);
> > +static int if_usb_probe(struct usb_interface *intf,
> > +			const struct usb_device_id *id);
> > +static void if_usb_disconnect(struct usb_interface *intf);
> > +#ifdef CONFIG_PM
> > +static int if_usb_suspend(struct usb_interface *intf, pm_message_t=
 message);
> > +static int if_usb_resume(struct usb_interface *intf);
> > +#else
> > +#define if_usb_suspend NULL
> > +#define if_usb_resume NULL
> > +#endif
>=20
> It would be good to avoid forward declarations by reordering the
> functions into their call order (bottom up).

Done.

> > +static void if_usb_write_bulk_callback(struct urb *urb)
> > +{
> > +	wlan_private *priv =3D (wlan_private *) (urb->context);
> > +	wlan_adapter *adapter =3D priv->adapter;
> > +	struct net_device *dev =3D priv->wlan_dev.netdev;
> > +
> > +	/* handle the transmission complete validations */
> > +
> > +	if (urb->status !=3D 0) {
> > +		/* print the failure status number for debug */
> > +		printk(KERN_INFO "URB in failure status\n");
> > +	} else {
> > +		dprintk(2, "URB status is successfull\n");
> > +		dprintk(2, "Actual length transmitted %d\n",
> > +		       urb->actual_length);
>=20
> The printk and dprintk statements should probably be converted
> to dev_info/dev_dbg/... standard macros, or something derived
> from that.
>=20
> > +void if_usb_free(struct usb_card_rec *cardp)
> > +{
> > +	ENTER();
>=20
> Do you find the ENTER() and LEAVE() macros really useful?
> usually, you're better off taking them out...

Yes, for instance the bug reported at http://dev.laptop.org/ticket/841
could be verified by checking the log file (by confirming that certain
states were true/false).

However, only a few such macros, on key functions, are required. I'll g=
o
over and remove the unneeded ones.

> > +	return (-ENOMEM);
>=20
> 	return -ENOMEM;

Done.

>=20
> > +	if (!(rinfo =3D kmalloc(sizeof(struct read_cb_info), GFP_ATOMIC))=
) {
> > +		printk(KERN_ERR "No free read_callback_info\n");
> > +		goto rx_ret;
> > +	}
>=20
> I usually find it more readable to do the assignment first, and have =
the
> error check in a separate line.

This one should be removed anyway, but yes, I get the point.

> > +struct BootCMDRespStr bootcmdresp;
> > +
>=20
> This variable is used only inside of one function, so you should
> be able to just put it on the stack (it's small).

Yeah, done.

> > +/** =20
> > + *  @brief This function reads of the packet into the upload buff,=
=20
> > + *  wake up the main thread and initialise the Rx callack.
> > + * =20
> > + *  @param urb		pointer to struct urb
> > + *  @return 	   	N/A
> > + */
> > +static void if_usb_receive(struct urb *urb)
> > +{
>=20
> This function is a little long, there is a switch() statement in it
> that can probably be converted into one function per case.
>=20
> > +/**=20
> > + *  @brief Given a usb_card_rec return its wlan_private
> > + *  @param card		pointer to a usb_card_rec
> > + *  @return 	   	pointer to wlan_private
> > + */
> > +wlan_private *libertas_sbi_get_priv(void *card)
> > +{
> > +	struct usb_card_rec *cardp =3D (struct usb_card_rec *)card;
> > +	return (wlan_private *)cardp->priv;
> > +}
>=20
> Don't do explicit casts of void* pointers.
>=20
> > +	data =3D *((int *)(wrq->u.name + SUBCMD_OFFSET));
>=20
> You use this weird line in many places, it would be good to make it
> a helper function.=20

This is part of WEXT API, I'm sorry. :)=20

Will turn it into a helper function.

> > +static u8 Is_Command_Allowed_In_PS(u16 Command)
> > +{
> > +	int count =3D sizeof(Commands_Allowed_In_PS)
> > +	    / sizeof(Commands_Allowed_In_PS[0]);
> > +	int i;
> > +
> > +	for (i =3D 0; i < count; i++) {
> > +		if (Command =3D=3D cpu_to_le16(Commands_Allowed_In_PS[i]))
> > +			return 1;
> > +	}
> > +
> > +	return 0;
> > +}
>=20
> In places where you use variables that are strictly little-endian,
> it would be nice to use the __le32/__le16 types instead of u32/u16.
>=20
> > +/**=20
> > + *  @brief This function handles the command response
> > + * =20
> > + *  @param priv    A pointer to wlan_private structure
> > + *  @return 	   WLAN_STATUS_SUCCESS or WLAN_STATUS_FAILURE
> > + */
> > +int libertas_process_rx_command(wlan_private * priv)
> > +{
>=20
> This function is incredibly long, to the point where it gets
> unreadable.
>=20
> > +static struct dentry *libertas_dir =3D NULL;
> > +static const int big_buffer_len =3D 4096;
> > +static char big_buffer[4096];
> > +static DECLARE_MUTEX(big_buffer_sem);
>=20
> This seems to provide a generalized interface for buffering debugfs
> files. Have you considered using the existing simple_attribute
> and seq_file interfaces instead?
>=20
> Even if they don't work for this, I would consider it cleaner to
> use get_zeroed_page/free_page instead of the global buffer here.
>=20
> > +static struct file_operations libertas_devinfo_fops =3D {=20
> > +	.owner =3D THIS_MODULE,
> > +	.open =3D open_file_generic,
> > +	.write =3D write_file_dummy,
> > +	.read =3D libertas_dev_info,
> > +};
> > +
> > +static struct file_operations libertas_getscantable_fops =3D {=20
> > +	.owner =3D THIS_MODULE,
> > +	.open =3D open_file_generic,
> > +	.write =3D write_file_dummy,
> > +	.read =3D libertas_getscantable,
> > +};
> > +
> > +static struct file_operations libertas_sleepparams_fops =3D {=20
> > +	.owner =3D THIS_MODULE,
> > +	.open =3D open_file_generic,
> > +	.write =3D libertas_sleepparams_write,
> > +	.read =3D libertas_sleepparams_read,
> > +};
>=20
> I would guess you can better express this with some array, like
>=20
> #define FOPS(read, write) { \
> 	.owner =3D THIS_MODULE, \
> 	.open =3D open_file_generic, \
> 	.read =3D (read), \
> 	.write =3D (write), \
> }
>=20
> struct libertas_debugfs_files {
> 	char *name;
> 	int perm;
> 	struct file_operations fops;
> } debugfs_files =3D {
> 	{ "devinfo", 0444, FOPS(libertas_dev_info, NULL), },
> 	{ "getscantable", 0444, FOPS(libertas_getscantable, NULL), },
> 	{ "sleepparams", 0644, FOPS(libertas_sleepparams_read,
> 					libertas_sleepparams_write), },
> 	...
> };
>=20
> > +void libertas_debugfs_init_one(wlan_private *priv, struct net_devi=
ce *dev)
> > +{
> > +	if (!libertas_dir)
> > +		goto exit;
> > +
> > +	priv->debugfs_dir =3D debugfs_create_dir(dev->name, libertas_dir)=
;
> > +	if (!priv->debugfs_dir)
> > +		goto exit;
> > +
> > +	priv->debugfs_devinfo =3D debugfs_create_file("info", 0444,
> > +						    priv->debugfs_dir,
> > +						    priv,
> > +						    &libertas_devinfo_fops);
>=20
> And then here do a loop over that array.
>=20
> > +/** Double-Word(32Bit) Bit definition */
> > +#define DW_BIT_0	0x00000001
> > +#define DW_BIT_1	0x00000002
> > +#define DW_BIT_2	0x00000004
> > +#define DW_BIT_3	0x00000008
> > +#define DW_BIT_4	0x00000010
> > +#define DW_BIT_5	0x00000020
> > +#define DW_BIT_6	0x00000040
> > +#define DW_BIT_7	0x00000080
> > +#define DW_BIT_8	0x00000100
> > +#define DW_BIT_9	0x00000200
> > +#define DW_BIT_10	0x00000400
> > +#define DW_BIT_11       0x00000800
> > +#define DW_BIT_12       0x00001000
> > +#define DW_BIT_13       0x00002000
> > +#define DW_BIT_14       0x00004000
> > +#define DW_BIT_15       0x00008000
> > +#define DW_BIT_16       0x00010000
> > +#define DW_BIT_17       0x00020000
> > +#define DW_BIT_18       0x00040000
> > +#define DW_BIT_19       0x00080000
> > +#define DW_BIT_20       0x00100000
> > +#define DW_BIT_21       0x00200000
> > +#define DW_BIT_22       0x00400000
> > +#define DW_BIT_23       0x00800000
> > +#define DW_BIT_24       0x01000000
> > +#define DW_BIT_25       0x02000000
> > +#define DW_BIT_26       0x04000000
> > +#define DW_BIT_27       0x08000000
> > +#define DW_BIT_28       0x10000000
> > +#define DW_BIT_29       0x20000000
> > +#define DW_BIT_30	0x40000000
> > +#define DW_BIT_31	0x80000000
>=20
> These should go away.
>
> > +
> > +/** Word (16bit) Bit Definition*/
> > +#define W_BIT_0		0x0001
> > +#define W_BIT_1		0x0002
> > +#define W_BIT_2		0x0004
> > +#define W_BIT_3		0x0008
> > +#define W_BIT_4		0x0010
> > +#define W_BIT_5		0x0020
> > +#define W_BIT_6		0x0040
> > +#define W_BIT_7		0x0080
> > +#define W_BIT_8		0x0100
> > +#define W_BIT_9		0x0200
> > +#define W_BIT_10	0x0400
> > +#define W_BIT_11	0x0800
> > +#define W_BIT_12	0x1000
> > +#define W_BIT_13	0x2000
> > +#define W_BIT_14	0x4000
> > +#define W_BIT_15	0x8000
> > +
> > +/** Byte (8Bit) Bit definition*/
> > +#define B_BIT_0		0x01
> > +#define B_BIT_1		0x02
> > +#define B_BIT_2		0x04
> > +#define B_BIT_3		0x08
> > +#define B_BIT_4		0x10
> > +#define B_BIT_5		0x20
> > +#define B_BIT_6		0x40
> > +#define B_BIT_7		0x80
>=20
> These as well.

Done.

> > +extern unsigned int libertas_debug;
> > +
> > +/** Debug Macro definition*/
> > +#ifdef	DEBUG
> > +#define dprintk(level,format, args...)	if (libertas_debug >=3D lev=
el) printk(KERN_INFO format, ##args)
> > +#else
> > +#define dprintk(format, args...)	do {} while (0)
> > +#endif
>=20
> dev_dbg should be enough, if you want it dynamic, you can use
> netif_msg_* together with dev_info.
>=20
> > +#define ASSERT(cond)						\
> > +do {								\
> > +	if (!(cond))						\
> > +		dprintk(1, "ASSERT: %s, %s:%i\n",		\
> > +		       __FUNCTION__, __FILE__, __LINE__);	\
> > +} while(0)
>=20
> just use WARN_ON instead of defining your own ASSERT

Done.

> > +#define	ENTER()			dprintk(1, "Enter: %s, %s:%i\n", __FUNCTION__, \
> > +							__FILE__, __LINE__)
> > +#define	LEAVE()			dprintk(1, "Leave: %s, %s:%i\n", __FUNCTION__, \
> > +							__FILE__, __LINE__)
>=20
> As mentioned, these should probably just be removed

I disagree, entry/exit points have been shown to be useful in practice
to identify firmware problems on field.

> > +
> > +#if defined(DEBUG)
> > +static inline void HEXDUMP(char *prompt, u8 * buf, int len)
> > +{
> > +	int i =3D 0;
> > +
> > +	if (!libertas_debug)
> > +		return;
> > +
> > +	printk(KERN_DEBUG "%s: ", prompt);
> > +	for (i =3D 1; i <=3D len; i++) {
> > +		printk(KERN_DEBUG "%02x ", (u8) * buf);
> > +		buf++;
> > +	}
> > +	printk("\n");
> > +}
> > +#else
> > +#define HEXDUMP(x,y,z)
> > +#endif
>=20
> The second definition should be an empty inline function so you don't=
 break
> for code like
>=20
> if (condition)
> 	HEXDUMP(x,y,z);
> else
> 	something_else();
>=20
> maybe rename to dev_dbg_hex() and move to the same place as the gener=
ic
> dev_dbg function.
>=20
> > +#ifndef NELEMENTS
> > +#define NELEMENTS(x) (sizeof(x)/sizeof(x[0]))
> > +#endif
>=20
> array_size()

Done.

> > +static int wlan_setup_station_hw(wlan_private * priv)
> > +{
> > +	int ret =3D WLAN_STATUS_FAILURE;
> > +	wlan_adapter *adapter =3D priv->adapter;
> > +
> > +	ENTER();
> > +
> > +	if ((ret =3D request_firmware(&priv->firmware, libertas_fw_name,
> > +				    priv->hotplug_device)) < 0) {
> > +		printk(KERN_ERR "request_firmware() failed, error code =3D %#x\n=
",
> > +		       ret);
> > +		printk(KERN_ERR "%s not found in /lib/firmware\n", libertas_fw_n=
ame);
> > +		goto done;
> > +	}
>=20
> Since we now have an Open Firmware based system, the libertas firmwar=
e
> could be stored inside of the firmware device tree. The most signific=
ant
> advantage of that is that you can boot with the libertas driver enabl=
ed
> before mounting the file system.
>=20
> Another advantage is that if we get a forth implementation of the dri=
ver
> that can do PXE boot, the open firmware can use the same copy of the
> libertas firmware blob as Linux.
>=20
> > diff --git a/drivers/net/wireless/libertas/wlan_ioctl.c b/drivers/n=
et/wireless/libertas/wlan_ioctl.c
> > new file mode 100644
> > index 0000000..0cc852b
> > --- /dev/null
> > +++ b/drivers/net/wireless/libertas/wlan_ioctl.c
> > @@ -0,0 +1,2814 @@
> > +/**=20
> > +  * This file contains ioctl functions
>=20
> The number of private ioctl functions defined in this file (and some
> other places is a hint that there is still something very wrong with
> this driver. The best solution I can think of is to throw them all
> away and add new interface for those that are really needed, but do
> it in a generic way, in the common wireless extensions for Linux.=20

But most of these ioctl's are driver-specific anyway (and I personally
consider it one of the good points of the driver, from a completness
POV).

> > +#define WLAN_TX_PWR_DEFAULT		20	/*100mW */
> > +#define WLAN_TX_PWR_US_DEFAULT		20	/*100mW */
> > +#define WLAN_TX_PWR_JP_DEFAULT		16	/*50mW */
> > +#define WLAN_TX_PWR_FR_DEFAULT		20	/*100mW */
> > +#define WLAN_TX_PWR_EMEA_DEFAULT	20	/*100mW */
> > +
> > +/* Format { Channel, Frequency (MHz), MaxTxPower } */
> > +/* Band: 'B/G', Region: USA FCC/Canada IC */
> > +static struct chan_freq_power channel_freq_power_US_BG[] =3D {
> > +	{1, 2412, WLAN_TX_PWR_US_DEFAULT},
> > +	{2, 2417, WLAN_TX_PWR_US_DEFAULT},
> > +	{3, 2422, WLAN_TX_PWR_US_DEFAULT},
> > +	{4, 2427, WLAN_TX_PWR_US_DEFAULT},
> > +	{5, 2432, WLAN_TX_PWR_US_DEFAULT},
> > +	{6, 2437, WLAN_TX_PWR_US_DEFAULT},
> > +	{7, 2442, WLAN_TX_PWR_US_DEFAULT},
> > +	{8, 2447, WLAN_TX_PWR_US_DEFAULT},
> > +	{9, 2452, WLAN_TX_PWR_US_DEFAULT},
> > +	{10, 2457, WLAN_TX_PWR_US_DEFAULT},
> > +	{11, 2462, WLAN_TX_PWR_US_DEFAULT}
> > +};
> > +
> > +/* Band: 'B/G', Region: Europe ETSI */
> > +static struct chan_freq_power channel_freq_power_EU_BG[] =3D {
> > +	{1, 2412, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{2, 2417, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{3, 2422, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{4, 2427, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{5, 2432, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{6, 2437, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{7, 2442, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{8, 2447, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{9, 2452, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{10, 2457, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{11, 2462, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{12, 2467, WLAN_TX_PWR_EMEA_DEFAULT},
> > +	{13, 2472, WLAN_TX_PWR_EMEA_DEFAULT}
> > +};
> > +
> > +/* Band: 'B/G', Region: Spain */
> > +static struct chan_freq_power channel_freq_power_SPN_BG[] =3D {
> > +	{10, 2457, WLAN_TX_PWR_DEFAULT},
> > +	{11, 2462, WLAN_TX_PWR_DEFAULT}
> > +};
> > +
> > +/* Band: 'B/G', Region: France */
> > +static struct chan_freq_power channel_freq_power_FR_BG[] =3D {
> > +	{10, 2457, WLAN_TX_PWR_FR_DEFAULT},
> > +	{11, 2462, WLAN_TX_PWR_FR_DEFAULT},
> > +	{12, 2467, WLAN_TX_PWR_FR_DEFAULT},
> > +	{13, 2472, WLAN_TX_PWR_FR_DEFAULT}
> > +};
> > +
> > +/* Band: 'B/G', Region: Japan */
> > +static struct chan_freq_power channel_freq_power_JPN_BG[] =3D {
> > +	{1, 2412, WLAN_TX_PWR_JP_DEFAULT},
> > +	{2, 2417, WLAN_TX_PWR_JP_DEFAULT},
> > +	{3, 2422, WLAN_TX_PWR_JP_DEFAULT},
> > +	{4, 2427, WLAN_TX_PWR_JP_DEFAULT},
> > +	{5, 2432, WLAN_TX_PWR_JP_DEFAULT},
> > +	{6, 2437, WLAN_TX_PWR_JP_DEFAULT},
> > +	{7, 2442, WLAN_TX_PWR_JP_DEFAULT},
> > +	{8, 2447, WLAN_TX_PWR_JP_DEFAULT},
> > +	{9, 2452, WLAN_TX_PWR_JP_DEFAULT},
> > +	{10, 2457, WLAN_TX_PWR_JP_DEFAULT},
> > +	{11, 2462, WLAN_TX_PWR_JP_DEFAULT},
> > +	{12, 2467, WLAN_TX_PWR_JP_DEFAULT},
> > +	{13, 2472, WLAN_TX_PWR_JP_DEFAULT},
> > +	{14, 2484, WLAN_TX_PWR_JP_DEFAULT}
> > +};
>=20
> None of this looks libertas specific to me. Is it perhaps already
> provided by the common code?

Yeah, it is. I'll look into using generic code.

Again, thanks!
