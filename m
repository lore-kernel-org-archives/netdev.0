From: Alex Gartrell <agartrell@fb.com>
Subject: Re: [PATCH net-next 2/2] tun: enable socket system calls
Date: Fri, 26 Dec 2014 14:16:32 -0500
Message-ID: <549DB410.8000002@fb.com>
References: <1419576624-8999-1-git-send-email-agartrell@fb.com> <1419576624-8999-3-git-send-email-agartrell@fb.com> <549D2DBE.5040301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Jason Wang <jasowang@redhat.com>, <davem@davemloft.net>,
	<herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <549D2DBE.5040301@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jason,

Thanks for commenting.

On 12/26/14 4:43 AM, Jason Wang wrote:
>
> On 12/26/2014 02:50 PM, Alex Gartrell wrote:
>> By setting private_data to a socket and private_data_is_socket to true, we
>> can use the socket syscalls.  We also can't just blindly use private_data
>> anymore, so there's a __tun_file_get function that returns the container_of
>> private_data appropriately.
>
> So this in fact expose other socket syscalls to userspace. But some of
> proto_ops was not supported. E.g consider what happens if a bind() was
> called for tun socket?

Yeah, I erroneously assumed that NULL => sock_no_*, but a quick glance 
assures me that that's not the case.  In this case, I'd need to 
introduce another patch that sets all of the additional ops to sock_no_*.

>> +static struct tun_file *tun_file_from_file(struct file *file)
>> +{
>> +	struct socket *s = (struct socket *)file->private_data;
>> +
>> +	if (!s)
>
> Can s be NULL here? If yes, why tun_get() didn't check for NULL?

This check is just to ensure that tun_get_socket continues to work in 
the right way when passed a file with private_data set to NULL.

Thanks,
-- 
Alex Gartrell <agartrell@fb.com>
