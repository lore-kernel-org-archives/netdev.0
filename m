From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch/bk] remove scm_cookie parameter to send/recvmsg
Date: Mon, 20 Jan 2003 21:14:16 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030120.211416.98847188.davem@redhat.com>
References: <20030120161755.B23890@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bcrl@redhat.com
In-Reply-To: <20030120161755.B23890@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Benjamin LaHaise <bcrl@redhat.com>
   Date: Mon, 20 Jan 2003 16:17:55 -0500

   +		memset(&scm, 0, sizeof(scm));
    		init_sync_kiocb(&iocb, NULL);
    		si = kiocb_to_siocb(&iocb);
    		si->sock = sock;
   -		si->scm = &si->async_scm;
   +		si->scm = &scm;
    		si->msg = &kern_msg;
    		si->size = total_len;
    		si->flags = user_flags;
    		memset(si->scm, 0, sizeof(*si->scm));

We're now memset()'ing it twice?  :)  I think the first
memset isn't needed, and this makes the code consistent with
the other places this logic is duplicated.

Otherwise the patch is fine, please fix this stuff up and
resubmit, thanks.
