From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2] net: introduce helper macro for_each_cmsghdr
Date: Wed, 10 Dec 2014 10:02:34 +0800
Message-ID: <5487A9BA.10208@cn.fujitsu.com>
References: <5487A455.1090907@cn.fujitsu.com> <1418176864.1047.6.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418176864.1047.6.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,
On 12/10/2014 10:01 AM, Joe Perches wrote:

> On Wed, 2014-12-10 at 09:39 +0800, Gu Zheng wrote:
>> Introduce helper macro for_each_cmsghdr as a wrapper of the enumerating
>> cmsghdr from msghdr, just cleanup. 
> 
> Does this even compile?
> 
> So which is it?
> 
> 	for_each_cmsghdr
> or
> 	for_each_cmsg_hdr?
> 
> The .h #defines for_each_cmsg_hdr
> but all the uses are for_each_cmsghdr

Thanks for your quick feedback.
There seems some problems with my send-patch script, it sent out the patch
before the test completed.

Thanks,
Gu

> 
>> diff --git a/Documentation/networking/timestamping/timestamping.c b/Documentation/networking/timestamping/timestamping.c
> []
>> @@ -169,9 +169,7 @@ static void printpacket(struct msghdr *msg, int res,
>>  	       res,
>>  	       inet_ntoa(from_addr->sin_addr),
>>  	       msg->msg_controllen);
>> -	for (cmsg = CMSG_FIRSTHDR(msg);
>> -	     cmsg;
>> -	     cmsg = CMSG_NXTHDR(msg, cmsg)) {
>> +	for_each_cmsghdr(cmsg, msg) {
>>  		printf("   cmsg len %zu: ", cmsg->cmsg_len);
>>  		switch (cmsg->cmsg_level) {
>>  		case SOL_SOCKET:
>> diff --git a/crypto/af_alg.c b/crypto/af_alg.c
> []
>> @@ -399,7 +399,7 @@ int af_alg_cmsg_send(struct msghdr *msg, struct af_alg_control *con)
>>  {
>>  	struct cmsghdr *cmsg;
>>  
>> -	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
>> +	for_each_cmsghdr(cmsg, msg) {
>>  		if (!CMSG_OK(msg, cmsg))
>>  			return -EINVAL;
>>  		if (cmsg->cmsg_level != SOL_ALG)
>> diff --git a/include/linux/socket.h b/include/linux/socket.h
> []
>> @@ -94,6 +94,10 @@ struct cmsghdr {
>>  			     (cmsg)->cmsg_len <= (unsigned long) \
>>  			     ((mhdr)->msg_controllen - \
>>  			      ((char *)(cmsg) - (char *)(mhdr)->msg_control)))
>> +#define for_each_cmsg_hdr(cmsg, msg)  \
>> +	for (cmsg = CMSG_FIRSTHDR(msg); \
>> +	     cmsg; \
>> +	     cmsg = CMSG_NXTHDR(msg, cmsg))
> 
> 
> 
> .
> 
