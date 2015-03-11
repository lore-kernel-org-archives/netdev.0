From: Tadeusz Struk <tadeusz.struk@intel.com>
Subject: Re: net: Remove iocb argument from sendmsg and recvmsg
Date: Wed, 11 Mar 2015 09:25:40 -0700
Message-ID: <55006C84.6040406@intel.com>
References: <54FFAA5B.3080608@intel.com>	<54FFB3E9.50905@windriver.com> <20150311.000607.609650379851507833.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hch@lst.de, viro@ZenIV.linux.org.uk,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: David Miller <davem@davemloft.net>, ying.xue@windriver.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150311.000607.609650379851507833.davem@davemloft.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/10/2015 09:06 PM, David Miller wrote:
> From: Ying Xue <ying.xue@windriver.com>
> Date: Wed, 11 Mar 2015 11:18:01 +0800
> 
>> Sorry, I did not realize the case when I created the commit. However, although I
>> don't understand its scenario, in my opinion, adding one redundant argument for
>> all sockets to satisfy the special case seems unreasonable for us.
> 
> And the AIO socket mechanism was buggy and references freed up stack
> objects.
> 
> That whole set of problems would need to be addressed fully before
> we could even think of adding AIO support back to the socket layer.
> 

Maybe we can add new sock_aio_read_iter() and sock_aio_write_iter() functions in socket.c, and set the 
aio_read() and aio_write() ptrs to these in the socket_file_ops struct.
Then we can add new async_sendmsg() and async_recvmsg() to struct proto_ops that will still take the struct kiocb.
These new async_sendmsg() and async_recvmsg() functions will be called from the sock_aio_read_iter() and sock_aio_write_iter()?
Do you want me to put a patch together?
