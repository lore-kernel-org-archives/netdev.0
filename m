From: margitsw@t-online.de (Margit Schubert-While)
Subject: Re: [patch 8/8]  prism54/islpci_dev: replace schedule_timeout() with msleep()
Date: Thu, 2 Sep 2004 12:21:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409021221.42287.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 02 Sep 2004, Maximilian scribeth:
> you didn't answer to the unit argument in favour of msleep.

Don't need to, here's msleep -
void msleep(unsigned int msecs)
{
        unsigned long timeout = msecs_to_jiffies(msecs);

        while (timeout) {
                set_current_state(TASK_UNINTERRUPTIBLE);
                timeout = schedule_timeout(timeout);
        }
}

In other words, with the subtle exception of the while loop,
it reconstitutes the original code.
(Although m_to_j doesn't even exactly do that)
(And note because of the while loop, this may not be 
 what the author intended)

> shure msleep is also consistent and documented.
grep -r Documentation = Nix

Margit
