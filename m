From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 for-next 04/12] IB/ipoib: Return IPoIB devices matching
 connection parameters
Date: Thu, 21 May 2015 08:48:45 +0300
Message-ID: <555D71BD.7040702@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1431841868-28063-5-git-send-email-haggaie@mellanox.com>
 <20150519235502.GB26634@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150519235502.GB26634-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 20/05/2015 02:55, Jason Gunthorpe wrote:
> On Sun, May 17, 2015 at 08:51:00AM +0300, Haggai Eran wrote:
>> For each ipoib device we iterate through all upper devices when searching
>> for a matching IP, in order to support bonding.
> 
> Checking an IP address in a packet against a device without consulting
> the routing table is a big red flag for me. Can you elaborate?
We want to match the incoming CM request to a specific net_dev, and use
the network namespace of that net_dev to find the right rdma_cm_id.
Because there can be multiple network namespaces, there would also be
multiple routing tables, so I'm not sure how we could use them. The
solution we used is to walk all the upper net_devs of all the IPoIB
child devices of a given IB device and port, and find one that matches
the request's IB device, port number, P_Key and IP address.

Regards,
Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
