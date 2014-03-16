From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Staging: gdm724x: gdm_lte.c: fixed coding style
Date: Sun, 16 Mar 2014 12:31:21 -0700
Message-ID: <1394998281.5689.63.camel@joe-AO722>
References: <20140316192025.GE3478@quad>
	 <1394997876.5689.60.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Kim <jonathankim@gctsemi.com>,
	Dean ahn <deanahn@gctsemi.com>, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Daniel Ngu <daniel.dy.ngu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394997876.5689.60.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-03-16 at 12:24 -0700, Joe Perches wrote:

> > @@ -551,28 +583,41 @@ static void gdm_lte_netif_rx(struct net_device *dev, char *buf, int len, int fla
> []
> >  			struct dhcp_packet {
> 
> This one would be better fixed by moving the struct definition
> out of this function altogether.
> 
> >  				u8 op;      /* BOOTREQUEST or BOOTREPLY */
> > -				u8 htype;   /* hardware address type. 1 = 10mb ethernet */
> > +				u8 htype;   /* hardware address type.
> > +					       1 = 10mb ethernet */
> >  				u8 hlen;    /* hardware address length */
> >  				u8 hops;    /* used by relay agents only */
> >  				u32 xid;    /* unique id */
> > -				u16 secs;   /* elapsed since client began acquisition/renewal */
> > +				u16 secs;   /* elapsed since client began
> > +					       acquisition/renewal */
> >  				u16 flags;  /* only one flag so far: */
> > -				#define BROADCAST_FLAG 0x8000 /* "I need broadcast replies" */
> > -				u32 ciaddr; /* client IP (if client is in BOUND, RENEW or REBINDING state) */
> > +				#define BROADCAST_FLAG 0x8000 /* "I need
> > +								 broadcast
> > +								 replies" */
> > +				u32 ciaddr; /* client IP (if client is in
> > +					       BOUND, RENEW or REBINDING
> > +					       state) */
> >  				u32 yiaddr; /* 'your' (client) IP address */
> > -				/* IP address of next server to use in bootstrap, returned in DHCPOFFER, DHCPACK by server */
> > +				/* IP address of next server to use in
> > +				 * bootstrap, returned in DHCPOFFER, DHCPACK by
> > +				 * server */
> >  				u32 siaddr_nip;
> >  				u32 gateway_nip; /* relay agent IP address */
> > -				u8 chaddr[16];   /* link-layer client hardware address (MAC) */
> > +				u8 chaddr[16];   /* link-layer client hardware
> > +						    address (MAC) */
> >  				u8 sname[64];    /* server host name (ASCIZ) */
> >  				u8 file[128];    /* boot file name (ASCIZ) */
> > -				u32 cookie;      /* fixed first four option bytes (99,130,83,99 dec) */
> > +				u32 cookie;      /* fixed first four option
> > +						    bytes (99,130,83,99 dec) */
> >  			} __packed;

Also, the net/ipv4/ipconfig.c definition
seems a lot more sensible as it uses endian
specific types

struct bootp_pkt {		/* BOOTP packet format */
	struct iphdr iph;	/* IP header */
	struct udphdr udph;	/* UDP header */
	u8 op;			/* 1=request, 2=reply */
	u8 htype;		/* HW address type */
	u8 hlen;		/* HW address length */
	u8 hops;		/* Used only by gateways */
	__be32 xid;		/* Transaction ID */
	__be16 secs;		/* Seconds since we started */
	__be16 flags;		/* Just what it says */
	__be32 client_ip;		/* Client's IP address if known */
	__be32 your_ip;		/* Assigned IP address */
	__be32 server_ip;		/* (Next, e.g. NFS) Server's IP address */
	__be32 relay_ip;		/* IP address of BOOTP relay */
	u8 hw_addr[16];		/* Client's HW address */
	u8 serv_name[64];	/* Server host name */
	u8 boot_file[128];	/* Name of boot file */
	u8 exten[312];		/* DHCP options / BOOTP vendor extensions */
};

It'd probably be better to make that struct definition public
and use it instead.
