From: Jason Baron <jbaron@akamai.com>
Subject: Re: strange Mac OSX RST behavior
Date: Fri, 22 Jul 2016 17:08:27 -0400
Message-ID: <d2aefee2-b11d-b93e-d3ad-6b4202bc7852@akamai.com>
References: <1467385815-6357-1-git-send-email-jbaron@akamai.com>
 <5776A3A4.8000503@hpe.com> <5776A607.70800@akamai.com>
 <20160701191609.1fc1c045@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160701191609.1fc1c045@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

After looking at this further we found that there is actually
a rate limit on 'rst' packets sent by OSX on a closed socket.
Its set to 250 per second and controlled via:
net.inet.icmp.icmplim. Increasing that limit resolves the
issue, but the default is apparently 250.

Thanks,

-Jason

On 07/01/2016 02:16 PM, One Thousand Gnomes wrote:
>> yes, we do in fact see a POLLRDHUP from the FIN in this case and
>> read of zero, but we still have more data to write to the socket, and
>> b/c the RST is dropped here, the socket stays in TIME_WAIT until
>> things eventually time out...
> After the FIN when you send/retransmit your next segment do you then get
> a valid RST back from the Mac end?
>
> Alan
