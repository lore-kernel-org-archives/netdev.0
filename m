From: Daniel McNeil <daniel@osdl.org>
Subject: Re: [PATCH 2.5.69] wanrouter clean up MOD_*_USE_COUNT
Date: 22 May 2003 09:14:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1053620053.2441.56.camel@ibm-c.pdx.osdl.net>
References: <1053550112.2444.35.camel@ibm-c.pdx.osdl.net>
	 <20030521231801.GE10295@conectiva.com.br>
	 <20030521.162707.88487215.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, ncorbic@sangoma.com, dm@sangoma.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030521.162707.88487215.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-05-21 at 16:27, David S. Miller wrote:
>    From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
>    Date: Wed, 21 May 2003 20:18:01 -0300
>    
>    Already submitted to DaveM, CCed netdev, I'll fix this later
>    tonight.
> 
> Note that, as I said in another email, these MOD_* calls can't just be
> deleted, the PROCFS registry etc. have to set ->owner fields correctly
> before this is valid.
> 
> By just removing MOD_*(), I can load just wanrouter, open a proc file,
> unload the wanrouter module, and crash.

The proc file looked like a separate problem.  The MOD_* calls I removed
were in register_wan_device/unregister_wan_device, so these did not
protect the procfs entries for wanrouter.  If another module called
register_wan_device, the wanrouter module couldn't be unloaded because
of the symbol reference.  Of course, the modules that call
register_wan_device also need to kept from being unloaded until
have unregister_wan_device.  Again, I thought these were separate
problems.

Arnaldo, sorry about the conflicting patch.  We in the middle of moving
and I hadn't had a chance to catch up on the mailing list.

-- 
Daniel McNeil <daniel@osdl.org>
