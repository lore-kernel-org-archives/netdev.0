From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH v4 1/9] rdma/cm: define native IB address
Date: Wed, 13 Feb 2013 14:51:11 +0200
Message-ID: <511B8C3F.9070002@mellanox.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com> <1358891797-14625-2-git-send-email-sean.hefty@intel.com> <1828884A29C6694DAF28B7E6B8A8237368B99D59@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller (davem@davemloft.net)" <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>
To: "Hefty, Sean" <sean.hefty@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:43701 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932508Ab3BMMvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 07:51:19 -0500
In-Reply-To: <1828884A29C6694DAF28B7E6B8A8237368B99D59@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2013 20:02, Hefty, Sean wrote:
>> Define AF_IB and sockaddr_ib to allow the rdma_cm to use native IB addressing.
>>
>> Signed-off-by: Sean Hefty <sean.hefty@intel.com>
>> ---
>>   include/linux/socket.h |    2 +
>>   include/rdma/ib.h      |   89 ++++++++++++++++++++++++++++++++++++++++++++++++
>>   2 files changed, 91 insertions(+), 0 deletions(-)
>>   create mode 100644 include/rdma/ib.h
>>
>> diff --git a/include/linux/socket.h b/include/linux/socket.h
>> index 9a546ff..17a33f7 100644
>> --- a/include/linux/socket.h
>> +++ b/include/linux/socket.h
>> @@ -167,6 +167,7 @@ struct ucred {
>>   #define AF_PPPOX	24	/* PPPoX sockets		*/
>>   #define AF_WANPIPE	25	/* Wanpipe API Sockets */
>>   #define AF_LLC		26	/* Linux LLC			*/
>> +#define AF_IB		27	/* Native InfiniBand address	*/
> ...
>
>> diff --git a/include/rdma/ib.h b/include/rdma/ib.h
> ...
>
>> +struct sockaddr_ib {
>> +	unsigned short int	sib_family;	/* AF_IB */
>> +	__be16			sib_pkey;
>> +	__be32			sib_flowinfo;
>> +	struct ib_addr		sib_addr;
>> +	__be64			sib_sid;
>> +	__be64			sib_sid_mask;
>> +	__u64			sib_scope_id;
>> +};
> Dave/Roland/anyone, is there any feedback on this approach?
>
> If there's hesitation to add new address families to socket.h, I could instead use definitions local to the rdma_cm.  This has the potential to result in conflicts if the rdma_cm is expanded for other address families, though such conflicts seem unlikely.
>
>

I don't see why not add new address family if it comes to serve a real 
world use case, which seems to be the case from the description you 
provided in the cover letter.

Or.
