From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: [PATCH v2 01/15] net: proc entry showing inodes on sockfs and
 their types
Date: Sun, 12 Aug 2012 15:44:16 +0900 (JST)
Message-ID: <20120812.154416.1611788053634506933.yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
	<20120811.210434.961670950702666620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120811.210434.961670950702666620.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Sorry, you cannot do this.
> 
> You are adding a new lock and insert into a global list for
> pretty much every socket created, that will destroy performance.

I think there are no serious performance penalty in generally use.
Most frequently used types of sockets like tcp, udp, and unix are not
stored to the global list and don't touch the new lock at all.
Please, look at has_own_proc_entry in struct proto.

> You also cannnot add new fields to socket listing procfs files,
> it will break existing application which depend upon the existing
> exact layout of those fields.

Is there any strcut which can be extended? 
Extending struct sock is o.k.?

Masatake YAMATO
