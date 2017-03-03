From: Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH-v4-RESEND 1/4] vsock: track pkt owner vsock
Date: Fri, 3 Mar 2017 09:25:54 +0800
Message-ID: <CA+a=Yy4T1WRZoYM3WPD0et7QzF0RYUtRerDS_X-dU5uABixTJw@mail.gmail.com>
References: <1488340587-32416-1-git-send-email-bergwolf@gmail.com>
	<1488340587-32416-2-git-send-email-bergwolf@gmail.com>
	<20170302.131303.703202861280343181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jorgen Hansen <jhansen@vmware.com>,
	Stefan Hajnoczi <stefanha@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20170302.131303.703202861280343181.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 5:13 AM, David Miller <davem@davemloft.net> wrote:
> From: Peng Tao <bergwolf@gmail.com>
> Date: Wed,  1 Mar 2017 11:56:24 +0800
>
>> So that we can cancel a queued pkt later if necessary.
>>
>> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
>> Signed-off-by: Peng Tao <bergwolf@gmail.com>
>> ---
>>  include/linux/virtio_vsock.h            | 2 ++
>>  net/vmw_vsock/virtio_transport_common.c | 7 +++++++
>>  2 files changed, 9 insertions(+)
>>
>> diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
>> index 9638bfe..193ad3a 100644
>> --- a/include/linux/virtio_vsock.h
>> +++ b/include/linux/virtio_vsock.h
>> @@ -48,6 +48,7 @@ struct virtio_vsock_pkt {
>>       struct virtio_vsock_hdr hdr;
>>       struct work_struct work;
>>       struct list_head list;
>> +     void *cancel_token; /* only used for cancellation */
>
> The type here is fixed, you only store vhost_sock object pointers
> here, so don't use "void *" please.
It used to be "struct vhost_sock *" but no refcount is held. Stefan
suggested to use "void *cancel_token" to make the code harder to
misuse.

Quoting Stefan:
"This field is just an opaque token used for cancellation rather than
a struct vsock_sock pointer that we are allowed to dereference.  You
could change this field to void *cancel_token to make the code harder
to misuse."

Ref:
https://www.mail-archive.com/netdev@vger.kernel.org/msg142550.html

Cheers,
Tao
