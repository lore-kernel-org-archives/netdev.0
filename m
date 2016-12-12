From: Peng Tao <bergwolf@gmail.com>
Subject: Re: [PATCH v3 0/4] vsock: cancel connect packets when failing to
	connect
Date: Mon, 12 Dec 2016 17:17:24 +0800
Message-ID: <CA+a=Yy4nsykS8sQVAsUny47t4kpfW_+wtz9Ld39y7AUCV0PcvQ@mail.gmail.com>
References: <1481217156-7160-1-git-send-email-bergwolf@gmail.com>
	<20161209101842.GD18260@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>,
	Stefan Hajnoczi <stefanha@redhat.com>, kvm@vger.kernel.org
To: Stefan Hajnoczi <stefanha@gmail.com>, Jorgen Hansen <jhansen@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20161209101842.GD18260@stefanha-x1.localdomain>
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

On Fri, Dec 9, 2016 at 6:18 PM, Stefan Hajnoczi <stefanha@gmail.com> wrote:
> On Fri, Dec 09, 2016 at 01:12:32AM +0800, Peng Tao wrote:
>> Currently, if a connect call fails on a signal or timeout (e.g., guest is still
>> in the process of starting up), we'll just return to caller and leave the connect
>> packet queued and they are sent even though the connection is considered a failure,
>> which can confuse applications with unwanted false connect attempt.
>>
>> The patchset enables vsock (both host and guest) to cancel queued packets when
>> a connect attempt is considered to fail.
>>
>> v3 changelog:
>>   - define cancel_pkt callback in struct vsock_transport rather than struct virtio_transport
>>   - rename virtio_vsock_pkt->vsk to virtio_vsock_pkt->cancel_token
>> v2 changelog:
>>   - fix queued_replies counting and resume tx/rx when necessary
>>
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
>
> I'm happy although I pointed out two unnecessary (void*) casts.
>
> Please wait for Jorgen to go happy on the af_vsock.c changes before
> applying.
Thanks for reviewing!

Jorgen, would you please see if the changes to af_vsock.c is OK to you?

Cheers,
Tao
