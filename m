From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] virtio_net: add gro capability
Date: Mon, 03 Aug 2015 09:22:48 -0700
Message-ID: <55BF9558.3020501@hp.com>
References: <1438359917.2748.18.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150803162529-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150803162529-mutt-send-email-mst@redhat.com>
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

On 08/03/2015 06:37 AM, Michael S. Tsirkin wrote:
> Ideally this needs to also be tested on non-vxlan configs with gro in
> host, to make sure this doesn't cause regressions.

Measured with the same instances on the same hardware and software, 
taking a path through the stack (public rather than private IPs, with 
Distributed Virtual Router (DVR) enabled) which gives them GRO:

Throughput				
	Min	Median	Average	Max
4.2.0-rc3+_hostGRO	6713	8351	8232	9102
4.2.0-rc3+flush1k_hostGRO	6539	8267	8206	8982

As singletons, Mins and Maxes probably have rather high variability, I'd 
focus on the Median and Average and those are within 1%.

Send Service Demand				
	Min	Median	Average	Max
4.2.0-rc3+_hostGRO	0.332	0.496	0.490	0.651
4.2.0-rc3+flush1k_hostGRO	0.328	0.493	0.488	0.678

Receive Service Demand				
	Min	Median	Average	Max
4.2.0-rc3+_hostGRO	0.386	0.469	0.485	0.677
4.2.0-rc3+flush1k_hostGRO	0.369	0.466	0.477	0.665

happy benchmarking,

rick
