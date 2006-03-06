From: Sean Hefty <mshefty@ichips.intel.com>
Subject: Re: Re: [PATCH 6/6] IB: userspace support for RDMA
	connection manager
Date: Mon, 06 Mar 2006 13:42:13 -0800
Message-ID: <440CACB5.2010609@ichips.intel.com>
References: <ORSMSX4011XvpFVjCRG00000009@orsmsx401.amr.corp.intel.com>
	<adaoe0j5kd6.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adaoe0j5kd6.fsf@cisco.com>
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

Roland Dreier wrote:
>  > +struct rdma_ucm_query_route_resp {
>  > +	__u64 node_guid;
>  > +	struct ib_user_path_rec ib_route[2];
>  > +	struct sockaddr_in6 src_addr;
>  > +	struct sockaddr_in6 dst_addr;
>  > +	__u32 num_paths;
>  > +	__u8 port_num;
>  > +	__u8 reserved[3];
>  > +};
> 
> Is there a 32-bit/64-bit compatibility problem here?  From a quick
> look, struct sockaddr_in6 is not 8-byte aligned.

Unless I miss counted, they should be aligned.  ib_user_path_rec is defined near 
the end of patch 1/6.

+struct ib_user_path_rec {
+	__u8	dgid[16];
+	__u8	sgid[16];
+	__be16	dlid;
+	__be16	slid;
+	__u32	raw_traffic;
+	__be32	flow_label;
+	__u32	reversible;
+	__u32	mtu;
+	__be16	pkey;
+	__u8	hop_limit;
+	__u8	traffic_class;
+	__u8	numb_path;
+	__u8	sl;
+	__u8	mtu_selector;
+	__u8	rate_selector;
+	__u8	rate;
+	__u8	packet_life_time_selector;
+	__u8	packet_life_time;
+	__u8	preference;
+};

- Sean
