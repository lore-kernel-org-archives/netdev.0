From: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH] NFS: Fix infinite loop in gss_create_upcall()
Date: Tue, 12 Apr 2011 20:05:33 +0200
Message-ID: <4DA4946D.5020403@suse.cz>
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org> <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org> <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz> <4DA36758.4070203@suse.cz> <4DA36DB6.8060108@suse.cz> <4DA48EB0.40600@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	mm-commits-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ML netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bryan Schumaker <bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4DA48EB0.40600-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/12/2011 07:41 PM, Bryan Schumaker wrote:
> On 04/11/2011 05:08 PM, Jiri Slaby wrote:
>>
>> Sorry for an extra message. I've just found out that there appears
>> messages in dmesg:
>> [   58.656048] RPC: AUTH_GSS upcall timed out.
>> [   58.656050] Please check user daemon is running.
>> [   88.656065] RPC: AUTH_GSS upcall timed out.
>> [   88.656068] Please check user daemon is running.
>> [  118.656077] RPC: AUTH_GSS upcall timed out.
>> [  118.656080] Please check user daemon is running.
>> [  148.656049] RPC: AUTH_GSS upcall timed out.
>> [  148.656052] Please check user daemon is running.
>> [  178.656046] RPC: AUTH_GSS upcall timed out.
>> [  178.656049] Please check user daemon is running.
>>
>>
>> I instrumented the code and it's stuck with trying RPC_AUTH_GSS_KRB5.
>>
>> I don't use GSS at all.
>>
>> regards,
> 
> Does this patch help?
> 
> - Bryan
> 
> 
> 
> There can be an infinite loop if gss_create_upcall() is called without
> the userspace program running.  To prevent this, we return -EACCES if
> we notice that pipe_version hasn't changed (indicating that the pipe
> has not been opened).

Yes, it fixes the problem. But it waits 15s before it times out. This is
inacceptable for automounted NFS dirs.

thanks,
-- 
js
suse labs
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
