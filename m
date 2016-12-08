From: Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH v2 1/4] vsock: track pkt owner vsock
Date: Thu, 8 Dec 2016 18:37:58 +0800
Message-ID: <CA+a=Yy5OMDSr12S3JZ3BeMhZKAZ0DAgOuAnSPG8TDw-wr-zzsg@mail.gmail.com>
References: <1481123652-80603-1-git-send-email-bergwolf@gmail.com>
	<1481123652-80603-2-git-send-email-bergwolf@gmail.com>
	<20161208093010.GC10780@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, kvm@vger.kernel.org,
	Stefan Hajnoczi <stefanha@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20161208093010.GC10780@stefanha-x1.localdomain>
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

On Thu, Dec 8, 2016 at 5:30 PM, Stefan Hajnoczi <stefanha@gmail.com> wrote:
> On Wed, Dec 07, 2016 at 11:14:09PM +0800, Peng Tao wrote:
>> So that we can cancel a queued pkt later if necessary.
>>
>> Signed-off-by: Peng Tao <bergwolf@gmail.com>
>> ---
>>  include/linux/virtio_vsock.h            | 2 ++
>>  net/vmw_vsock/virtio_transport_common.c | 7 +++++++
>>  2 files changed, 9 insertions(+)
>>
>> diff --git a/include/linux/virtio_vsock.h b/include/linux/virtio_vsock.h
>> index 9638bfe..6dd3242 100644
>> --- a/include/linux/virtio_vsock.h
>> +++ b/include/linux/virtio_vsock.h
>> @@ -48,6 +48,7 @@ struct virtio_vsock_pkt {
>>       struct virtio_vsock_hdr hdr;
>>       struct work_struct work;
>>       struct list_head list;
>> +     struct vsock_sock *vsk;
>
> To prevent future bugs, please add a comment here:
> /* socket refcnt not held, only use for cancellation */
>
> This field is just an opaque token used for cancellation rather than a
> struct vsock_sock pointer that we are allowed to dereference.  You could
> change this field to void *cancel_token to make the code harder to
> misuse.
Will do. Thanks!

Cheers,
Tao
