From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [iproute2] IPoIB link layer address bug
Date: Tue, 21 Mar 2006 15:56:17 -0800
Message-ID: <20060321155617.3ae419b2@localhost.localdomain>
References: <Pine.LNX.4.61.0603161707360.23670@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	openib-general <openib-general@openib.org>, lartc@mailman.ds9a.nl
Return-path: <openib-general-bounces@openib.org>
To: James Lentini <jlentini@netapp.com>
In-Reply-To: <Pine.LNX.4.61.0603161707360.23670@jlentini-linux.nane.netapp.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Mar 2006 17:24:41 -0500 (EST)
James Lentini <jlentini@netapp.com> wrote:

> 
> The ip(8) command has a bug when dealing with IPoIB link layer 
> addresses. Specifically it does not correctly handle the addition of 
> new entries in the neighbor/arp table. For example, this command will 
> fail:
> 
> ip neigh add 192.168.0.138 lladdr 00:00:04:04:fe:80:00:00:00:00:00:00:00:01:73:00:00:00:8a:91 nud permanent dev ib0
> 
> An IPoIB link layer address is 20-bytes (see 
> http://www.ietf.org/internet-drafts/draft-ietf-ipoib-ip-over-infiniband-09.txt, 
> section 9.1.1).
> 
> The command line parsing code expects link layer addresses to be a 
> maximum of 16-bytes. Addresses over 16-bytes are truncated.
> 
> This patch (against the iproute2 cvs repository) fixes the problem:
> 

Okay, but there are number of other places in iproute2 that call ll_addr_a2n()
with ifr.ifr_hwaddr.sa_data. And that is 14 bytes.  If you want to fix those
it will be harder since it would increase the sizeof(struct sockaddr) and potentially
break compatibility.
