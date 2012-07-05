From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [net-next RFC V5 0/5] Multiqueue virtio-net
Date: Thu, 05 Jul 2012 10:45:27 -0700
Message-ID: <4FF5D2B7.6080602@hp.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, mashirle@us.ibm.com,
	kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
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

On 07/05/2012 03:29 AM, Jason Wang wrote:

>
> Test result:
>
> 1) 1 vm 2 vcpu 1q vs 2q, 1 - 1q, 2 - 2q, no pinning
>
> - Guest to External Host TCP STREAM
> sessions size throughput1 throughput2   norm1 norm2
> 1 64 650.55 655.61 100% 24.88 24.86 99%
> 2 64 1446.81 1309.44 90% 30.49 27.16 89%
> 4 64 1430.52 1305.59 91% 30.78 26.80 87%
> 8 64 1450.89 1270.82 87% 30.83 25.95 84%

Was the -D test-specific option used to set TCP_NODELAY?  I'm guessing 
from your description of how packet sizes were smaller with multiqueue 
and your need to hack tcp_write_xmit() it wasn't but since we don't have 
the specific netperf command lines (hint hint :) I wanted to make certain.

Instead of calling them throughput1 and throughput2, it might be more 
clear in future to identify them as singlequeue and multiqueue.

Also, how are you combining the concurrent netperf results?  Are you 
taking sums of what netperf reports, or are you gathering statistics 
outside of netperf?

> - TCP RR
> sessions size throughput1 throughput2   norm1 norm2
> 50 1 54695.41 84164.98 153% 1957.33 1901.31 97%

A single instance TCP_RR test would help confirm/refute any non-trivial 
change in (effective) path length between the two cases.

happy benchmarking,

rick jones
