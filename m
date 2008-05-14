From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: POHMELFS high performance network filesystem. Transactions,
 failover, performance.
Date: Tue, 13 May 2008 23:33:41 -0700
Message-ID: <20080513233341.47edea7f.akpm@linux-foundation.org>
References: <20080513174523.GA1677@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20080513174523.GA1677@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 May 2008 21:45:24 +0400 Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> I'm please to announce POHMEL high performance network filesystem.

If any thread takes more than one kmap() at a time, it is deadlockable.
Because there is a finite pool of kmaps.  Everyone can end up holding
one or more kmaps, then waiting for someone else to release one.

Duplicating page_waitqueue() is bad.  Exporting it is probably bad too.
Better would be to help us work out why the core kernel infrastructure is
unsuitable, then make it suitable.
