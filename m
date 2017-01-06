From: Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH v4 0/4] vsock: cancel connect packets when failing to
	connect
Date: Fri, 6 Jan 2017 10:22:56 +0800
Message-ID: <CA+a=Yy7d940_OfNL=b_qZjnpRVL5pywKFpubtS_h6OtB7c2Dmg@mail.gmail.com>
References: <1481545269-18104-1-git-send-email-bergwolf@gmail.com>
	<20161213095010.GA3103@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, kvm@vger.kernel.org,
	Jorgen Hansen <jhansen@vmware.com>, Stefan Hajnoczi <stefanha@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Stefan Hajnoczi <stefanha@gmail.com>, David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20161213095010.GA3103@stefanha-x1.localdomain>
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

On Tue, Dec 13, 2016 at 5:50 PM, Stefan Hajnoczi <stefanha@gmail.com> wrote:
> On Mon, Dec 12, 2016 at 08:21:05PM +0800, Peng Tao wrote:
>> Currently, if a connect call fails on a signal or timeout (e.g., guest is still
>> in the process of starting up), we'll just return to caller and leave the connect
>> packet queued and they are sent even though the connection is considered a failure,
>> which can confuse applications with unwanted false connect attempt.
>>
>> The patchset enables vsock (both host and guest) to cancel queued packets when
>> a connect attempt is considered to fail.
>>
>> v4 changelog:
>>   - drop two unnecessary void * cast
>>   - update new callback commnet
>> v3 changelog:
>>   - define cancel_pkt callback in struct vsock_transport rather than struct virtio_transport
>>   - rename virtio_vsock_pkt->vsk to virtio_vsock_pkt->cancel_token
>> v2 changelog:
>>   - fix queued_replies counting and resume tx/rx when necessary
>>
>> Cheers,
>> Tao
>>
>> Peng Tao (4):
>>   vsock: track pkt owner vsock
>>   vhost-vsock: add pkt cancel capability
>>   vsock: add pkt cancel capability
>>   vsock: cancel packets when failing to connect
>>
>>  drivers/vhost/vsock.c                   | 41 ++++++++++++++++++++++++++++++++
>>  include/linux/virtio_vsock.h            |  2 ++
>>  include/net/af_vsock.h                  |  3 +++
>>  net/vmw_vsock/af_vsock.c                | 14 +++++++++++
>>  net/vmw_vsock/virtio_transport.c        | 42 +++++++++++++++++++++++++++++++++
>>  net/vmw_vsock/virtio_transport_common.c |  7 ++++++
>>  6 files changed, 109 insertions(+)
>>
>> --
>> 2.7.4
>>
>> _______________________________________________
>> Virtualization mailing list
>> Virtualization@lists.linux-foundation.org
>> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
>
> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
ping~

It looks like the patchsets are reviewed but not merged. Is there any blocker?

Cheers,
Tao
