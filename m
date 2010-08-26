From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Thu, 26 Aug 2010 08:21:38 -0700
Message-ID: <20100826082138.76bcd315@nehalam>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com>
	<20100812141240.417949e2@s6510>
	<EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com>
	<20100818144124.33a72453@nehalam>
	<20100819213314.GA26135@auslistsprd01.us.dell.com>
	<20100819145308.0fa08522@nehalam>
	<20100825220323.GA12671@auslistsprd01.us.dell.com>
	<20100825171646.3d40b721@nehalam>
	<20100826150116.GB21770@auslistsprd01.us.dell.com>
	<D3F292ADF945FB49B35E96C94C2061B90CEAD321@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Matt Domsch" <Matt_Domsch@Dell.com>, <Narendra_K@Dell.com>,
	<netdev@vger.kernel.org>, <Charles_Rose@Dell.com>,
	<Jordan_Hargrave@Dell.com>, <linux-pci@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90CEAD321@nsmail.netscout.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Aug 2010 11:17:51 -0400
"Loke, Chetan" <Chetan.Loke@netscout.com> wrote:

> What if we extend 'IFNAMSIZ'(beyond 16 chars. Older apps don't need to
> worry because they have been working w/ 16 chars anyways) and also get
> ifalias to work in udev(Or is ifalias a bad idea?)?
> 
> Chetan
>
That is  non-starter for the ioctl() style interface.

struct ifreq {
#define IFHWADDRLEN	6
	union
	{
		char	ifrn_name[IFNAMSIZ];		/* if name, e.g. "en0" */
	} ifr_ifrn;
	
	union {
		struct	sockaddr ifru_addr;
		struct	sockaddr ifru_dstaddr;
		struct	sockaddr ifru_broadaddr;
		struct	sockaddr ifru_netmask;
		struct  sockaddr ifru_hwaddr;
		short	ifru_flags;
		int	ifru_ivalue;
		int	ifru_mtu;
		struct  ifmap ifru_map;
		char	ifru_slave[IFNAMSIZ];	/* Just fits the size */
		char	ifru_newname[IFNAMSIZ];
		void __user *	ifru_data;
		struct	if_settings ifru_settings;
	} ifr_ifru;
};

Applications do:
   	strncpy(ifr.ifr_name, "my name", IFNAMSIZ);
	ioctl(fd, SIOCGHWADDR, &ifr)

